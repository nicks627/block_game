# Godot ブロック崩しゲーム 開発仕様書

## プロジェクト概要
Godot 4.x を使用した2Dブロック崩しゲームの開発

## 技術要件
- Godot Engine 4.x
- 言語: GDScript
- 解像度: 1024x768
- フレームレート: 60 FPS

## プロジェクト構造
```
BreakoutGame/
├── project.godot
├── scenes/
│   ├── Main.tscn (メインゲームシーン)
│   ├── UI.tscn (UIシーン)
│   ├── Paddle.tscn (パドルシーン)
│   ├── Ball.tscn (ボールシーン)
│   ├── Block.tscn (ブロックシーン)
│   └── GameOver.tscn (ゲームオーバーシーン)
├── scripts/
│   ├── GameManager.gd
│   ├── Paddle.gd
│   ├── Ball.gd
│   ├── Block.gd
│   └── UI.gd
├── assets/
│   ├── textures/
│   └── sounds/
└── README.md
```

## ゲーム仕様

### 基本ゲームプレイ
1. プレイヤーはマウスまたはキーボード（A/Dキー）でパドルを左右に操作
2. ボールがパドルに当たると跳ね返る
3. ブロックにボールが当たるとブロックが消滅し、スコアが加算
4. 全ブロックを破壊するとゲームクリア
5. ボールが画面下に落ちるとライフが減り、0になるとゲームオーバー

### ゲームオブジェクト詳細

#### 1. パドル (Paddle)
**シーンノード構成:**
- CharacterBody2D (Root)
  - CollisionShape2D
  - Sprite2D

**仕様:**
- サイズ: 100x20 ピクセル
- 色: 青色 (#0080FF)
- 移動速度: 400 pixel/秒
- 移動範囲: 画面左端から右端（パドル幅の半分をマージンとして確保）
- 入力方式: マウス追従 または A/Dキー

**スクリプト要件:**
```gdscript
# 主要な関数
- _ready(): 初期化処理
- _process(delta): マウス追従処理
- _input(event): キーボード入力処理
- move_paddle(direction, delta): パドル移動処理
```

#### 2. ボール (Ball)
**シーンノード構成:**
- CharacterBody2D (Root)
  - CollisionShape2D
  - Sprite2D

**仕様:**
- サイズ: 20x20 ピクセル（円形）
- 色: 白色 (#FFFFFF)
- 初期速度: 300 pixel/秒
- 最大速度: 500 pixel/秒
- 初期位置: パドルの上（ゲーム開始時）
- 物理: カスタム物理（重力なし）

**動作仕様:**
- スペースキーでゲーム開始（ボール発射）
- 壁（左、右、上）で反射
- パドルとの衝突で反射角度変更
- ブロックとの衝突で反射＋ブロック破壊
- 画面下端でライフ減少

**スクリプト要件:**
```gdscript
# 主要な変数
var velocity: Vector2
var speed: float = 300.0
var is_started: bool = false

# 主要な関数
- _ready(): 初期化
- _physics_process(delta): 物理更新
- start_ball(): ボール発射
- reset_position(): 位置リセット
- _on_body_entered(body): 衝突処理
```

#### 3. ブロック (Block)
**シーンノード構成:**
- StaticBody2D (Root)
  - CollisionShape2D
  - Sprite2D

**仕様:**
- サイズ: 60x30 ピクセル
- 色: 段によって異なる（上から赤、オレンジ、黄、緑、青）
- 配置: 8列 × 5段 = 40個
- 間隔: 横5px、縦5px
- スコア: 上段ほど高得点（50, 40, 30, 20, 10点）

**スクリプト要件:**
```gdscript
# 主要な変数
var score_value: int
var block_color: Color

# 主要な関数
- _ready(): 初期化（色とスコア設定）
- destroy_block(): ブロック破壊処理
- _on_ball_collision(): ボール衝突時の処理
```

#### 4. ゲームマネージャー (GameManager)
**責務:**
- ゲーム状態管理（プレイ中、一時停止、ゲームオーバー、クリア）
- スコア管理
- ライフ管理
- レベル管理
- UI更新
- ブロック配置
- サウンド管理

**ゲーム状態:**
```gdscript
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    GAME_CLEAR
}
```

**主要変数:**
```gdscript
var score: int = 0
var lives: int = 3
var current_state: GameState = GameState.MENU
var blocks_remaining: int = 40
var paddle: CharacterBody2D
var ball: CharacterBody2D
var ui: Control
```

**主要関数:**
```gdscript
- _ready(): ゲーム初期化
- setup_blocks(): ブロック配置
- add_score(points): スコア加算
- lose_life(): ライフ減少
- check_win_condition(): 勝利条件チェック
- check_lose_condition(): 敗北条件チェック
- restart_game(): ゲーム再開
- pause_game(): 一時停止
```

#### 5. UI システム
**表示要素:**
- スコア表示（右上）
- ライフ表示（左上）
- ゲーム状態表示（中央）
- 操作説明（下部）

**UI仕様:**
```
スコア: Score: 000000
ライフ: Lives: ♥♥♥
状態表示: "PRESS SPACE TO START" / "GAME OVER" / "YOU WIN!"
操作説明: "Mouse or A/D keys to move, SPACE to start/pause"
```

## 物理設定

### 衝突レイヤー
- Layer 1: Walls（壁）
- Layer 2: Paddle（パドル）
- Layer 3: Ball（ボール）
- Layer 4: Blocks（ブロック）

### 衝突マスク
- Ball: Layer 1, 2, 4（壁、パドル、ブロックと衝突）
- Paddle: Layer 3（ボールとのみ衝突）
- Blocks: Layer 3（ボールとのみ衝突）

## 音響効果（オプション）
- パドル衝突音
- ブロック破壊音
- 壁反射音
- ゲームオーバー音
- ゲームクリア音

## 追加機能（拡張案）
1. パワーアップアイテム
2. 複数ボール
3. レベル制
4. ハイスコア記録
5. パーティクルエフェクト

## 開発優先順位
1. 基本的なゲームループ（パドル、ボール、ブロック）
2. UI実装
3. ゲーム状態管理
4. サウンド実装
5. 追加機能

## 実装注意点
- Godot 4.xのCharacterBody2Dを使用してスムーズな物理を実現
- シーンの分離によるモジュラー設計
- シグナルシステムを活用したオブジェクト間通信
- リソースの適切な管理
- 60FPSでの安定動作を保証

## 完了基準
- ゲームが最初から最後まで正常に動作する
- UI表示が正しく機能する
- 衝突判定が適切に動作する
- ゲームオーバー・クリア条件が正しく判定される
- 再起動機能が正常に動作する