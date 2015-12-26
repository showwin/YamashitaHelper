require 'clockwork'
require 'daemons'
require_relative './yh_mail'
require_relative './yh_scraper'

# Clockwork Module
module Clockwork
  class << self
    # for test
    attr_reader :today_str, :ystday_str, :scrp
    attr_accessor :today_updated, :yesterday_updated

    TARGET_URL = 'http://www.iryohoken.go.jp/shinryohoshu'

    # 日付変更時の初期化と生存報告
    # param: today はデバッグ/テストの時に日時を指定するために使う
    def daily_init(today = nil, debug = nil)
      @yesterday_updated = @today_updated
      @today_updated = false

      today ||= Date.today
      ystday = today - 1
      @today_str = "#{today.year - 2000 + 12}年#{today.month}月#{today.day}日"
      @ystday_str = "#{ystday.year - 2000 + 12}年#{ystday.month}月#{ystday.day}日"

      YHMail.report_running unless debug
    end

    # メイン処理
    def check_site(debug_page = nil, debug = nil)
      @scrp = YHScraper.new(debug_page || TARGET_URL, debug)
      if @scrp.dom_changed?
        YHMail.report_error unless debug
        return
      end

      has_new_update = today_has_new_update? || yesterday_has_new_update?
      YHMail.report_update if has_new_update && !debug

      # 今回の結果を保存
      @today_updated = today_has_new_update?
      @yesterday_updated = yesterday_has_new_update?
    end

    private

    # 今日の日付で更新されたのを*初めて*検知した?
    #   (1) 09:00チェックの時点で、今日00:00 ~ 今日09:00 に更新されたのを検知
    #   (2) 17:00チェックの時点で、今日09:00 ~ 今日17:00 に更新されたのを検知
    def today_has_new_update?
      f1 = @scrp.text1.include?('医薬品マスター更新') && @scrp.date1.include?(@today_str)
      f1 && !@today_updated
    end

    # 昨日の日付で更新されたのを*初めて*検知した?
    #   (1) 09:00チェックの時点で、昨日17:00 ~ 昨日24:00 に更新されたのを検知
    def yesterday_has_new_update?
      f1 = @scrp.text1.include?('医薬品マスター更新') && @scrp.date1.include?(@ystday_str)
      f2 = @scrp.text2.include?('医薬品マスター更新') && @scrp.date2.include?(@ystday_str)
      (f1 || f2) && !@yesterday_updated
    end
  end

  # 時間になるとこれが発動
  handler do |job|
    send(job.to_sym)
  end

  # スケジュール
  every(1.day, 'check_site', at: '09:00')
  every(1.day, 'check_site', at: '17:00')
  every(1.day, 'daily_init', at: '00:00')

  # 起動時に初期化
  @today_updated = false
  @yesterday_updated = false
  daily_init(nil, true)
end
