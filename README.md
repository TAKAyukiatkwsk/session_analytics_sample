This is sample scripts for analyzing trend of conference sessions. Analyze with NLP.

# How to work

```sh
bundle install --path vendor/bundle
# require COGNITIVE_SERVICE_KEY and API_ENDPOINT envvar
DATA_PATH=./data/Sessions\ paticipated\ -\ all.csv bundle exec ruby key_phrase_analytics.rb > key_phrase.csv

# require GOOGLE_APPLICATION_CREDENTIALS envvar
DATA_PATH=./data/Sessions\ paticipated\ -\ all.csv NGRAM_MODE=unigram bundle exec ruby cloud_syntax_analytics.rb > cloud_syntax_analytics.csv

DATA_PATH=./data/Sessions\ paticipated\ -\ all.csv NGRAM_MODE=bigram bundle exec ruby syntax_analytics.rb > syntax_analytics.csv
```
