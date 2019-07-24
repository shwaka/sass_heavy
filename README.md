# 概要
めっちゃ長い SASS (SCSS) ソースをコンパイルしたときの挙動を調査する．
元々問題が発生した環境が Jekyll 下だったので，そのまま流用

# 結論
`@extend` がヤバかった

# 実験
`jekyll build --watch` で更新を監視した状態で，
`test.scss` の `{% assign n = (数字) %}` の行を変えていった結果が以下の表．

|    n |   時間 |
|-----:|-------:|
|   10 |   0.04 |
|   30 |   0.39 |
|   60 |   3.05 |
|   90 |   8.95 |
|   99 |  11.70 |
|  100 |   1.60 |
|  200 |   6.41 |
|  300 |  13.46 |
|  500 |  39.61 |
| 1000 | 195.00 |

- `n=100` で謎の最適化(？)が働いて，コンパイル時間が大幅に減少する(参考: 下記の出力結果)
- `n=100` 以降は，概ね `O(n^2)` と思って良さそう

## ソースコード

```scss:test.scss
---
---

{% assign n = 100 %}
{{ "n = " | append: n | warn }}

{% for i in (1..n) %}
body.hoge-{{i}}{
  div{
    color: red;
  }
  span{
    @extend div;
  }
}
{% endfor %}
```

## `n=99` の出力結果
- ファイルサイズ: 5426 B
- 行数: 296 行

```css:test.css
body.hoge-1 div, body.hoge-1 span {
  color: red; }

body.hoge-2 div, body.hoge-2 span {
  color: red; }

(以下これが 99 まで続く)
```

## `n=100` の出力結果
- ファイルサイズ: 635915 B
- 行数: 299 行

出力は以下の通り．
ただし， `,` の後の改行は見易さのために勝手に追加したもの．

```css:test.css
body.hoge-1 div,
body.hoge-1 span,
body.hoge-1 body.hoge-2 span,
body.hoge-2 body.hoge-1 span,
body.hoge-1 body.hoge-3 span,
body.hoge-3 body.hoge-1 span,
body.hoge-1 body.hoge-4 span,
body.hoge-4 body.hoge-1 span,
body.hoge-1 body.hoge-5 span,
body.hoge-5 body.hoge-1 span,
        (中略)
body.hoge-1 body.hoge-98 span,
body.hoge-98 body.hoge-1 span,
body.hoge-1 body.hoge-99 span,
body.hoge-99 body.hoge-1 span,
body.hoge-1 body.hoge-100 span,
body.hoge-100 body.hoge-1 span {
  color: red;
}

body.hoge-2 div,
body.hoge-2 body.hoge-1 span,
body.hoge-1 body.hoge-2 span,
body.hoge-2 span,
body.hoge-2 body.hoge-3 span,
body.hoge-3 body.hoge-2 span,
body.hoge-2 body.hoge-4 span,
body.hoge-4 body.hoge-2 span,
body.hoge-2 body.hoge-5 span,
body.hoge-5 body.hoge-2 span,
        (中略)
body.hoge-2 body.hoge-100 span,
body.hoge-100 body.hoge-2 span {
  color: red;
}

(以下これが 100 まで続く)
```
