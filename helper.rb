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
    living
  end
  
  #生存報告メール送信
  def self.living
    f = open("pass.txt")
    pass = f.read
    mail = Mail.new do
      from    'yamashita.helper@gmail.com'
      to      'yamashita.helper@gmail.com'
      subject '生存報告'
      body    "山下さんヘルパーは正常に動いています"
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
  
  #メイン処理
  def self.check_site
    #初期化
    url = "http://www.iryohoken.go.jp/shinryohoshu"
    year = Date.today.year-2000+12
    month = Date.today.month
    today = Date.today.day
    yesterday = (Date.today-1).day
    update_flg = false
    t_flg = false
    y_flg = false
    
    #スクレイピング
    page = open(url).read
    document = Nokogiri::HTML(page, nil, 'SHIFT_JIS')
    elms = document.xpath('//div[@class="news"]/center/table/tr[2]/td[2]/table/tr')

    #過去2回分の更新を確認
    2.times do |i|
      date = elms[i*3+1].xpath('./td').first.content
      content = elms[i*3+2].xpath('./td')[1].content
      #今回のチェック結果
      t_flg = true if content.include?("医薬品マスター更新") && date.include?("#{year}年#{month}月#{today}日")
      y_flg = true if content.include?("医薬品マスター更新") && date.include?("#{year}年#{month}月#{yesterday}日")
    end
  end
    
  #メイン処理
  def self.check_site
    #初期化
    url = "http://www.iryohoken.go.jp/shinryohoshu"
    #year = Date.today.year-2000+12
    #month = Date.today.month
    #today = Date.today.day
    year = 26
    month = 3
    day = 26
    yesterday = (Date.today-1).day
    update_flg = false
    t_flg = false
    y_flg = false

    #スクレイピング
    page = open(url).read
    document = Nokogiri::HTML(page, nil, 'SHIFT_JIS')
    elms = document.xpath('//div[@class="news"]/center/table/tr[2]/td[2]/table/tr')

    #過去2回分の更新を確認
    2.times do |i|
      date = elms[i*3+1].xpath('./td').first.content
      content = elms[i*3+2].xpath('./td')[1].content
      #今回のチェック結果
      t_flg = true if content.include?("医薬品マスター更新") && date.include?("#{year}年#{month}月#{today}日")
      y_flg = true if content.include?("医薬品マスター更新") && date.include?("#{year}年#{month}月#{yesterday}日")
    end
    
    #今回のチェックで新しく見つかった場合にメールを送信
    send_flg = (t_flg && !@today_flg) || (y_flg && !@yesterday_flg)
    send_email if send_flg
    p send_flg
    #今回の結果を保存
    @today_flg = t_flg
    @yesterday_flg = y_flg
  end
  
  #メール送信
  def self.send_email
    f = open("pass.txt")
    pass = f.read
    mail = Mail.new do
      from    'yamashita.helper@gmail.com'
      to      'showwin_kmc@yahoo.co.jp'
      subject '医薬品マスター更新のお知らせ'
      body    "山下さん\nお疲れ様です。\n\n【医薬品マスター】が更新されました。\nご確認ください。\nhttp://www.iryohoken.go.jp/shinryohoshu"
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

  #時間になるとこれが発動
  handler do |job|
    self.send(job.to_sym)
  end
  
  every(1.day, 'check_site2', :at => '00:41')
  
  #スケジュール
  every(1.day, 'check_site', :at => '09:00')
  every(1.day, 'check_site', :at => '17:00')
  every(1.day, 'day_init', :at => '00:00')
  
end