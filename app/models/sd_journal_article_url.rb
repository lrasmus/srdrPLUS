class SdJournalArticleUrl < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_journal_article_urls
end
