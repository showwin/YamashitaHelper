require 'nokogiri'
require 'open-uri'

# YamashitaHelper Scraper Class
class YHScraper
  attr_reader :date1, :text1, :date2, :text2
  UPDATE_HISTORY_TABLE_XPATH = '//div[@class="news"]/center/table/tr[2]/td[2]/table/tr'

  def initialize(url, debug = nil)
    # spec/fixtures/*.html は文字コード: UTF-8
    # 実際のサイトは文字コード: SHIFT_JIS
    str_code = debug ? 'UTF-8' : 'SHIFT_JIS'

    doc = Nokogiri::HTML(open(url).read, nil, str_code)
    elms = doc.xpath(UPDATE_HISTORY_TABLE_XPATH)

    # 過去2回分の更新を取得
    begin
      @date1 = elms[0].xpath('./td')[0].content
      @text1 = elms[1].xpath('./td')[1].content
      @date2 = elms[3].xpath('./td')[0].content
      @text2 = elms[4].xpath('./td')[1].content
    rescue
      begin
        @date1 = elms[1].xpath('./td')[0].content
        @text1 = elms[2].xpath('./td')[1].content
        @date2 = elms[4].xpath('./td')[0].content
        @text2 = elms[5].xpath('./td')[1].content
      rescue
        @cannot_scrape = true
      end
    end
  end

  def dom_changed?
    @cannot_scrape || !date1.include?('年')
  end
end
