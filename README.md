# ScrapHelp

- Scrapboxページを検索する機能
- Scrapboxページに書いているヘルプ(Helpfeel記法)を検索する機能
- 例
  - ![](https://i.gyazo.com/ac8e1882e0035a21a2712a9b360187a9.png)
    - ScrapboxのページにHelpfeel記法で書いているヘルプ
  - ![](https://i.gyazo.com/0dd8a0062bd8fb9a8a96f52d110d4a48.png)
  - テキストタイプのヘルプなので`git commit --allow-empty -m "Initial commit"`をクリップボードにコピーする
- テキストタイプとURLタイプのヘルプがあり、URLタイプのヘルプはブラウザで開かれる

## Flow Launcher Plugin

### Dev

- FlowLauncher/Pluginsディレクトリにapps/flowディレクトリのsymlinkを貼る

```
mklink /J C:\Users\USER\AppData\Roaming\FlowLauncher\Plugins\scrap-help C:\Users\USER\repo\scrap-help\apps\flow
```
