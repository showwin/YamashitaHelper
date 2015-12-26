require 'mail'

# YamashitaHelper Mail Class
class YHMail
  class << self
    # 生存報告メール
    def report_running
      deliver(
        '生存報告',
        '山下さんヘルパーは正常に動いています',
        'yamashita.helper@gmail.com'
      )
    end

    # 医薬品マスターが更新された通知
    def repote_update
      deliver(
        '医薬品マスター更新のお知らせ',
        "山下さん\nお疲れ様です。\n\n【医薬品マスター】が更新されました。\nご確認ください。\nhttp://www.iryohoken.go.jp/shinryohoshu",
        ENV['YH_YAMASHITA_EMAIL_ADDRESS']
      )
    end

    # スクリプト修正依頼通知
    def repote_error
      deliver(
        '医薬品マスターのHTML構造が変わりました',
        "【医薬品マスター】のHTML構造が変わりました。\n修正してください。\nhttp://www.iryohoken.go.jp/shinryohoshu",
        'showwin.czy@gmail.com'
      )
    end

    # メール送信
    def deliver(mail_subject, mail_body, mail_to)
      mail = Mail.new do
        from 'yamashita.helper@gmail.com'
        to mail_to
        subject mail_subject
        body mail_body
      end

      mail.delivery_method(:smtp, {
        address: 'smtp.gmail.com',
        port: 587,
        user_name: 'yamashita.helper@gmail.com',
        password: ENV['YH_GMAIL_PASSWORD'],
        authentication: 'plain',
        enable_starttls_auto: true
      })
      mail.deliver
    end
  end
end
