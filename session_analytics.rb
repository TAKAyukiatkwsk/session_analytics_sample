require 'CSV'
require 'azure_cognitiveservices_textanalytics'

include Azure::CognitiveServices::TextAnalytics::V2_1::Models

credentials =
    MsRestAzure::CognitiveServicesCredentials.new(ENV['COGNITIVE_SERVICE_KEY'])
endpoint = String.new(ENV['API_ENDPOINT'])

textAnalyticsClient =
    Azure::TextAnalytics::Profiles::Latest::Client.new({
        credentials: credentials
    })
textAnalyticsClient.endpoint = endpoint

def read_data(path)
  documents = []
  CSV.foreach(path, headers: true) do |row|
    input = MultiLanguageInput.new
    input.id = row[0]
    input.text = row[1]
    input.language = 'ja'
    documents << input
  end
  documents
end

input_documents = MultiLanguageBatchInput.new
input_documents.documents = read_data(ENV['DATA_PATH'])
result = textAnalyticsClient.key_phrases(
  multi_language_batch_input: input_documents
)

if (!result.nil? && !result.documents.nil? && result.documents.length > 0)
  result.documents.each do |document|
    puts "Document Id: #{document.id}"
    puts '  Key Phrases'
    document.key_phrases.each do |key_phrase|
      puts "    #{key_phrase}"
    end
  end
else
  puts 'No results data..'
end


