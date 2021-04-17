# PC-8001 内蔵シリアルドライバー

## 概要

* PC-8001 本体基板内蔵シリアル端子と接続して通信するためのドライバー。
    * I/Oアドレス 20h/21hの8251をドライブする
    * N-BASICのUSR関数からのCallで使用する

## 使い方
* N-BASICのUSR関数(機械語サブルーチン)として呼び出して使用する。
  * 8251初期化データはの指定順番は下位1バイト目→上位1バイト目の順で8251へ出力されます。注意してください。
  * 入力バッファは128バイトです。バッファフルまたはCRやLFを受信した場合にN-BASICに戻ります。
```
5 CLEAR 300,&hE8FF
10 DEFUSR1=&HE900   ' 8251 init
20 DEFUSR2=&hE903   ' serial read
30 DEFUSR3=&hE906   ' serial Write
40 DEFUSR4=&hE909   ' 8251 to CMT
50 IN%=&h4E40
60 A%=USR1(IN%)
70 INPUT "SEND:";SE$
80 A$=USR3(SE$)
90 RE$=""+""
100 RE$=USR(RE$):PRINT "RECV:";RE$
110 A=USER4(0) 
```

## 参考
* SBC8080データパック
    * http://www.amy.hi-ho.ne.jp/officetetsu/storage/sbc8080_datapack.zip