# frozen_string_literal: true

require 'CSV'
require 'azure_cognitiveservices_textanalytics'

include Azure::CognitiveServices::TextAnalytics::V2_1::Models

credentials =
  MsRestAzure::CognitiveServicesCredentials.new(ENV['COGNITIVE_SERVICE_KEY'])
endpoint = String.new(ENV['API_ENDPOINT'])

text_analytics_client =
  Azure::TextAnalytics::Profiles::Latest::Client.new(
    credentials: credentials
  )
text_analytics_client.endpoint = endpoint

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
result = text_analytics_client.key_phrases(
  multi_language_batch_input: input_documents
)

if !result.nil? && !result.documents.nil? && !result.documents.empty?
  key_phrases = result.documents.map(&:key_phrases).flatten
  aggregate = key_phrases.group_by(&:itself).map { |k, v| [k, v.size] }
                         .sort { |a, b| b[1] <=> a[1] }
  puts Hash[aggregate]
else
  puts 'No results data..'
end
