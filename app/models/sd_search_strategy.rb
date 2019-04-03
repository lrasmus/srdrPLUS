class SdSearchStrategy < ApplicationRecord
  include SharedProcessTokenMethods

  belongs_to :sd_meta_datum, inverse_of: :sd_search_strategies
  belongs_to :sd_search_database, inverse_of: :sd_search_strategies

  def sd_search_database_id=(token)
    save_resource_name_with_token(SdSearchDatabase.new, token)
    super
  end
end
