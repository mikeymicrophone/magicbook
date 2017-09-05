module ScribesHelper
  def review_kit
    if current_scribe
      tag.div :class => 'header_links' do
        link_to('Review new lists', review_lists_path) +
        link_to('Review new items', review_listed_items_path)
      end
    end
  end
end
