# Kantan-GUI
## 概要
このスクリプトは、手軽にシンプルなフォームアプリを作成できるPowershellスクリプトです。サンプルは[こちら](./doc/sample.md)

## 情報
* 開発者 : ほっぴんぐがのん
* バージョン : 0.3

## 配置
作成したいフォームアプリのフォルダ内に"KantanGUI.ps1"ファイル(以下、メインスクリプト)を置いてください。また、メインスクリプトから相対パスで参照できる場所にレイアウトJSONファイル(以下、レイアウトファイル)を置いてください。

## メインスクリプト使用方法
### KantanGUI-Show
メインスクリプトをpowershellで実行したのち、"KantanGUI-Show"コマンドレットを実行してください。
引数にはメインスクリプトからレイアウトファイルへの相対パスを指定します。

"LayoutName"はメインスクリプトを配置した場所からの相対位置を指定してください。

引数名|説明|
|:-|:-|
|LayoutName|レイアウトファイル|
|ArgumentList|フォームコンポーネントに設定する初期値|

(例)
```
. .\KantanGUI.ps1
KantanGUI-Show 'layout\***.json' @{File="C:\\sample.csv"}
```

## レイアウトファイル設定方法
レイアウトはJSONで記述します。1階層にはフォーム全体の情報を記述し、Components配列に配置したいコンポーネントを記述します。記述しやすいように、コンポーネントは上から順に一つずつ配置されます。

レイアウトファイルの記述例はサンプルの"layout\sample.json"を参照してください。

### ROOT
|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Version|数値|0|KantanGUIのバージョンを指定。現状は指定しても何も変わらない。|
|Title|文字列|""|フォームのタイトルを指定。現状は現状は指定しても何も変わらない。|
|TitleBar|文字列|""|フォームのタイトルバーに表示する文字列を指定する。|
|Width|数値|0|フォームの幅を指定する。0を指定すると自動で決定する。|
|Height|数値|0|フォームの高さを指定する。0を指定すると自動で決定する。|
|StartY|数値|5|コンポーネントの配置を開始する高さを指定する。|
|PaddingX|数値|2|コンポーネント間隔(横)を指定する。|
|PaddingY|数値|2|コンポーネント間隔(縦)を指定する。|
|Components|Component[] |必須|コンポーネントの配置を[Component](#Component)配列で決定する。|

### Component
Component配列を指定。
Componentはフォームに配置するコンポーネントを上から順番に記述する。配置したいコンポーネントを"Type"に指定する。

|Type|種類|説明|
|:-|:-|:-|
|[Label](#Label)|ラベル|文字列を表示するだけのラベル。|
|[Title](#Title)|タイトル|大きなフォントのラベル。|
|[Blank](#Blank)|空白|ただの空白。|
|[Text](#Text)|テキスト入力ボックス|入力可能なテキストボックス。|
|[Number](#Number)|数値入力ボックス|数値のみ入力可能なテキストボックス(負数や小数点数も入力可能)。|
|[Check](#Check)|チェックボックス|クリックするとオンオフが切り替わるチェックボックス。|
|[List](#List)|リストボックス|クリックするとプルダウンでリスト表示されるリストボックス。|
|[OpenFile](#OpenFile)|ファイルを開く|ファイル入力ボックスと「開く」ボタン。|
|[OpenFolder](#OpenFolder)|フォルダを開く|フォルダ入力ボックスと「開く」ボタン。|
|[SaveFile](#SaveFile)|ファイルを保存|ファイル入力ボックスと「保存」ボタン。|
|[SaveFolder](#SaveFolder)|フォルダを保存|フォルダ入力ボックスと「保存」ボタン。|
|[ButtonCmd](#ButtonCmd)|コマンド実行ボタン|指定したコマンドを実行するボタン。|
|[ButtonCmdNamed](#ButtonCmdNamed)|コマンド実行ボタン2|指定したコマンドを名前付きパラメータとして引数を指定して実行するボタン。|
|[ButtonForm](#ButtonForm)|フォーム実行ボタン|フォームを開くボタン。|
|[ButtonOK](#ButtonOK)|OKボタン|OKボタン。|
|[ButtonCancel](#ButtonCancel)|キャンセルボタン|キャンセルボタン。|

また、Typeに指定したコンポーネントに付与するオプションを続けて記述する。

#### Label

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ラベルの文字列。|

#### Title

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ラベルの文字列。|

#### Blank

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Height|文字列|0|空白コンポーネントの高さ。|

#### Text

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### Number

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|0|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。また、falseにすると空白文字での登録が可能になる。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### Check

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|false|コンポーネントの初期値。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### List

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|Items|文字列|[]|リストボックスの選択肢を文字列配列で指定する。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### OpenFile

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|DandD|真偽値|false|trueを指定するとフォームにファイルをドロップしたときにそのパスを取得する。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### OpenFolder

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|DandD|真偽値|false|trueを指定するとフォームにフォルダをドロップしたときにそのパスを取得する。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### SaveFile

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|真偽値|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### SaveFolder

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|配置したコンポーネントの横に表示する文字列。|
|Default|文字列|""|コンポーネントの初期値。|
|Required|真偽値|false|trueを指定すると必須バリデーションチェックの対象にする。|
|Return|真偽値|false|実行ボタンを押したときに引数や戻り値に含むかどうか。|

#### ButtonCmd

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ボタンに表示する文字列。|
|Target|文字列|""|実行する対象ファイルを指定する。|
|Validation|真偽値|false|trueを指定するとボタン押下時にバリデーションチェックを行う。|
|Close|文字列|"Always"|実行後にフォームを閉じるかどうかを指定する。常に閉じる(`"Always"`)。成功時のみ閉じる(`"Success"`)。失敗時のみ閉じる(`"Failure"`)。閉じない(`"None"`)。|

#### ButtonCmdNamed

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ボタンに表示する文字列。|
|Target|文字列|""|実行する対象ファイルを指定する。|
|Validation|真偽値|false|trueを指定するとボタン押下時にバリデーションチェックを行う。|
|Close|文字列|"Always"|実行後にフォームを閉じるかどうかを指定する。常に閉じる(`"Always"`)。成功時のみ閉じる(`"Success"`)。失敗時のみ閉じる(`"Failure"`)。閉じない(`"None"`)。|

#### ButtonForm

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ボタンに表示する文字列。|
|Target|文字列|""|実行する対象ファイルを指定する。|
|Validation|真偽値|false|trueを指定するとボタン押下時にバリデーションチェックを行う。|
|Close|文字列|"Always"|実行後にフォームを閉じるかどうかを指定する。常に閉じる(`"Always"`)。成功時のみ閉じる(`"Success"`)。失敗時のみ閉じる(`"Failure"`)。閉じない(`"None"`)。|

#### ButtonOK

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ボタンに表示する文字列。|
|Target|文字列|""|実行する対象ファイルを指定する。|
|Validation|真偽値|false|trueを指定するとボタン押下時にバリデーションチェックを行う。|
|Close|文字列|"Always"|実行する対象ファイルを指定する。|
|Close|文字列|"Always"|実行後にフォームを閉じるかどうかを指定する。常に閉じる(`"Always"`)。成功時のみ閉じる(`"Success"`)。失敗時のみ閉じる(`"Failure"`)。閉じない(`"None"`)。|

#### ButtonCancel

|名前|型|規定値|説明|
|:-|:-|:-|:-|
|Id|文字列|""|コンポーネントに設定する固有のID。引数から初期値を変更する場合や、戻り値を取得する際に使用する。|
|Label|文字列|""|ボタンに表示する文字列。|
