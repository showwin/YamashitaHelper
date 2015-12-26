YamashitaHelper
===============
[![Circle CI](https://circleci.com/gh/showwin/YamashitaHelper.svg?style=svg)](https://circleci.com/gh/showwin/YamashitaHelper)

[診療報酬情報提供サービス](http://www.iryohoken.go.jp/shinryohoshu/) の `最新の更新情報` 欄に  `医薬品マスター更新` の文字列があるかどうかを1日2回確認し、更新されていれば山下さんにメールを送るプログラム。

## 使い方
1. ソースコードを持ってきて、gemをインストール。
  ```
  $ git clone git@github.com:showwin/YamashitaHelper.git
  $ cd YamashitaHelper
  $ bundle install
  ```

2. スクリプトをデーモン化して実行する
  ```
  $ clockworkd -c main.rb start --log
  ```

### Tips
* ログは `./tmp/clockworkd.main.output` に出力される。
* スクリプトが動いているかどうかは、`yamashita.helper@gmail.com`に毎日生存確認メールが送られているので、そちらを見るほうがログを見るよりも早いかもしれない。
* デーモン化されたプロセスのIDは`clockworkd.main.pid`で確認できる。
* スクリプトを止める時には `$ clockworkd -c main.rb stop`
