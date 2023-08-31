# U-22プログラミングコンテスト「TapNDonate」

## U-22向けの実行方法
1. 事務局指定のストレージより実行ファイル一式を展開
2. README.txtに従ってiOSおよびAndroidインストール

<br />

## U-22以外の実行方法(iOSエミュレータ)

### モバイルサイド

1. Google Map APIを取得する([わかりやすいサイト](https://qiita.com/Haruka-Ogawa/items/997401a2edcd20e61037))
2. project/ios/Runner/AppDelegate.swiftのYOURAPIKEYに自分のキーを入力する
3. iOS SimulatorでiPhone14を起動
4. この`README.md`と同じ階層で`make all-start`

### バックエンドサイド

0. 12月頃までサーバが動き続けているので, 以下はしなくて良い
1. `cp ./flask/.env.sample ./flask/.env`をして、API情報を入力
2. `cd config`
3. `make dcup`
4. `make back`
終了時は
5. `make down`

<br />

## 補足説明
### PayPay Developerアカウントに関して
[PayPayAPI](https://developer.paypay.ne.jp/)を使用して、dev用のアカウントを使用している。そのため、本コンテスト内で決済するには下記のアカウントが必要になる.

1. PayPayがインストールされていない場合は, PayPayをインストールする.
インストールされている場合は, **右下「アカウント」→ 右上「詳細」** よりログアウトをする.
2. ログイン画面にて, 左上の **「PayPayロゴを7回タップ」** して, dev用に変更する. そして, 下記アカウント情報でログインする.([詳しくはこちら](https://integration.paypay.ne.jp/hc/ja/articles/4414061901199-%E3%83%86%E3%82%B9%E3%83%88%E7%92%B0%E5%A2%83%E3%81%A7PayPay%E3%82%A2%E3%83%97%E3%83%AA%E3%82%92%E5%88%A9%E7%94%A8%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%81%8B-))
\* 下記アカウントは先述したdev用のアカウントであるため, 支払った金額は全て架空の金額となる.また, 日常で使うPayPayの決済にこのアカウントの残高は使用できない.

- Tel: `08049766295`
- Pass: `AC6L0KVjMg`
- OTP: `1234`

3. ログインが完了すればPayPayに関しては終了である. 通知を押せば, このアカウントに対して支払いが発生する.