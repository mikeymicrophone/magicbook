module ExternalLinkHelper
  def facebook_link
    link_to image_tag(asset_path('facebook-logo.png')), ENV['FACEBOOK_PAGE_URL'], :target => '_blank'
  end
  
  def youtube_link
    link_to image_tag(asset_path('youtube-logo.png')), ENV['YOUTUBE_PAGE_URL'], :target => '_blank'
  end
  
  def twitter_link
    link_to image_tag(asset_path('twitter-logo.png')), ENV['TWITTER_PAGE_URL'], :target => '_blank'
  end
  
  def ways_we_mage_social_links
    tag.div :id => 'ways_we_mage_socially' do
      facebook_link + youtube_link + twitter_link
    end
  end
end
