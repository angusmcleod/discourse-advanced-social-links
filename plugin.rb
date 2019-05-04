# name: discourse-advanced-social-links
# about: Add per-topic media to social meta tags
# version: 0.1
# author: Angus McLeod

after_initialize do
  require_dependency 'helpers/application_helper'
  ApplicationHelper.module_eval do
    def crawlable_meta_data(opts = nil)
      opts ||= {}
      opts[:url] ||= "#{Discourse.base_url_no_prefix}#{request.fullpath}"
      opts[:image] = "https://api.imageee.com/article?title=#{opts[:title].gsub(/\s/,'+')}&url=https://forum.coworking.org&desc=&img=https://forum.coworking.org/uploads/default/original/1X/fccd838d5edd0dd7bfd5bc2e5b061c2b3343a24c.png&bg_color=0076A9"

      result = []
      result << tag(:meta, property: 'og:site_name', content: SiteSetting.title)

      result << tag(:meta, name: 'twitter:card', content: "summary_large_image")
      result << tag(:meta, name: "twitter:image", content: opts[:image])
      result << tag(:meta, property: "og:image", content: opts[:image]) if opts[:image].present?

      [:url, :title, :description].each do |property|
        if opts[property].present?
          content = (property == :url ? opts[property] : gsub_emoji_to_unicode(opts[property]))
          result << tag(:meta, { property: "og:#{property}", content: content }, nil, true)
          result << tag(:meta, { name: "twitter:#{property}", content: content }, nil, true)
        end
      end

      if opts[:read_time] && opts[:read_time] > 0 && opts[:like_count] && opts[:like_count] > 0
        result << tag(:meta, name: 'twitter:label1', value: I18n.t("reading_time"))
        result << tag(:meta, name: 'twitter:data1', value: "#{opts[:read_time]} mins 🕑")
        result << tag(:meta, name: 'twitter:label2', value: I18n.t("likes"))
        result << tag(:meta, name: 'twitter:data2', value: "#{opts[:like_count]} ❤")
      end

      if opts[:published_time]
        result << tag(:meta, property: 'article:published_time', content: opts[:published_time])
      end

      if opts[:ignore_canonical]
        result << tag(:meta, property: 'og:ignore_canonical', content: true)
      end

      result.join("\n")
    end
  end
end
