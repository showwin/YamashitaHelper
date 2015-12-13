require 'clockwork'
require 'mail'
require 'nokogiri'
require 'open-uri'

module Clockwork

  #初期化
  @today_flg = false
  @yesterday_flg = false

  #日付変更時の初期化と生存報告
  def self.day_init
    @yesterday_flg = @today_flg
    @today_flg = false
    send_living_mail
  end

  # メール送信
  def self.deliver_mail(mail_subject, mail_body, mail_to = nil)
    f = open('pass.txt')
    address, pass = f.read.split
    mail_to ||= address
    mail = Mail.new do
      from    'yamashita.helper@gmail.com'
      to      mail_to
      subject mail_subject
      body    mail_body
    end

    mail.delivery_method :smtp, {
      address:   'smtp.gmail.com',
      port:      587,
      user_name: 'yamashita.helper@gmail.com',
      password: pass,
      authentication: 'plain',
      enable_starttls_auto: true
    }

    mail.deliver
  end

  # 生存報告メール
  def self.send_living_mail
    deliver_mail(
      '生存報告',
      '山下さんヘルパーは正常に動いています'
    )
  end

  # 医薬品マスターが更新された通知
  def self.send_update_email
    deliver_mail(
      '医薬品マスター更新のお知らせ',
      "山下さん\nお疲れ様です。\n\n【医薬品マスター】が更新されました。\nご確認ください。\nhttp://www.iryohoken.go.jp/shinryohoshu"
    )
  end

  # スクリプト修正依頼通知
  def self.send_error_mail
    deliver_mail(
      '医薬品マスターのHTML構造が変わりました',
      "【医薬品マスター】のHTML構造が変わりました。\n修正してください。\nhttp://www.iryohoken.go.jp/shinryohoshu",
      'showwin.czy@gmail.com'
    )
  end

  # メイン処理
  def self.check_site
    # 初期化
    url = 'http://www.iryohoken.go.jp/shinryohoshu'
    t_year = Date.today.year-2000+12
    t_month = Date.today.month
    t_day = Date.today.day
    y_year = (Date.today-1).year-2000+12
    y_month = (Date.today-1).month
    y_day = (Date.today-1).day
    update_flg = false
    t_flg = false
    y_flg = false

    # スクレイピング
    page = open(url).read
    document = Nokogiri::HTML(page, nil, 'SHIFT_JIS')
    elms = document.xpath('//div[@class="news"]/center/table/tr[2]/td[2]/table/tr')

    # 過去2回分の更新を確認
    2.times do |i|
      date = elms[i*3].xpath('./td').first.content
      content = elms[i*3+1].xpath('./td')[1].content

      # HTMLの構造が変わっていたら通知
      send_error_mail unless date.include?('年')

      # 今回のチェック結果
      t_flg = true if content.include?("医薬品マスター更新") && date.include?("#{t_year}年#{t_month}月#{t_day}日")
      y_flg = true if content.include?("医薬品マスター更新") && date.include?("#{y_year}年#{y_month}月#{y_day}日")
    end

    # 今回のチェックで新しく見つかった場合にメールを送信
    send_flg = (t_flg && !@today_flg) || (y_flg && !@yesterday_flg)
    send_update_email if send_flg

    # 今回の結果を保存
    @today_flg = t_flg
    @yesterday_flg = y_flg
  end

  # テスト
  def self.test
    # 初期化
    url = "http://www.iryohoken.go.jp/shinryohoshu"
    t_year = 27
    t_month = 11
    t_day = 1
    y_year = 27
    y_month = 10
    y_day = 31
    update_flg = false
    t_flg = false
    y_flg = false

    # スクレイピング
    page = open(url).read
    document = Nokogiri::HTML(page, nil, 'SHIFT_JIS')
    elms = document.xpath('//div[@class="news"]/center/table/tr[2]/td[2]/table/tr')

    # 過去2回分の更新を確認
    2.times do |i|
      date = elms[i*3].xpath('./td').first.content
      content = elms[i*3+1].xpath('./td')[1].content

      # HTMLの構造が変わっていたら通知
      send_error_mail unless date.include?('年')

      # 今回のチェック結果
      t_flg = true if content.include?("医薬品マスター更新") && date.include?("#{t_year}年#{t_month}月#{t_day}日")
      y_flg = true if content.include?("医薬品マスター更新") && date.include?("#{y_year}年#{y_month}月#{y_day}日")
    end

    # 今回のチェックで新しく見つかった場合にメールを送信
    send_flg = (t_flg && !@today_flg) || (y_flg && !@yesterday_flg)
    # send_update_email if send_flg
    p send_flg

    # 今回の結果を保存
    @today_flg = t_flg
    @yesterday_flg = y_flg
  end

  # 時間になるとこれが発動
  handler do |job|
    self.send(job.to_sym)
  end

  # スケジュール
  every(1.day, 'check_site', at: '09:00')
  every(1.day, 'check_site', at: '17:00')
  every(1.day, 'day_init', at: '00:00')
end
