# MongoMapper → Mongoid 段階的移行検証

Rails アプリケーションで MongoMapper から Mongoid への段階的移行が可能かを実証するプロジェクトです。

## 🎯 プロジェクトの目的

既存の MongoMapper を使用したプロダクションアプリケーションを、ダウンタイムなしで Mongoid に移行するための検証を行います。

### 💡 なぜ段階的移行が必要？
- **リスク軽減**: 一度に全てを変更するのは危険
- **継続運用**: サービスを停止せずに移行
- **検証可能**: 機能ごとに移行結果を確認
- **ロールバック**: 問題時の切り戻しが容易

## ⚡ クイックスタート

```bash
# 1. MongoDB 起動
docker run --name mongodb-test -p 27017:27017 -d mongo:latest

# 2. アプリケーション起動
bundle install
rails server

# 3. 動作確認
curl http://localhost:3000/shared_items
```

## 🏗️ アーキテクチャ概要

本プロジェクトは同一 Rails アプリケーション内で2つのODMを共存させ、段階的移行の可能性を実証します。

### 技術スタック
- **Ruby**: 3.3.5
- **Rails**: 8.0.2.1 (API mode)  
- **MongoMapper**: 0.17.0 (移行元)
- **Mongoid**: 9.0.7 (移行先)
- **MongoDB**: Docker コンテナ (localhost:27017)

### プロジェクト構造
```
├── app/models/
│   ├── mm_user.rb           # MongoMapper独立コレクション用
│   ├── md_user.rb           # Mongoid独立コレクション用
│   ├── mm_shared_item.rb    # MongoMapper共有コレクション用
│   └── md_shared_item.rb    # Mongoid共有コレクション用
├── config/initializers/
│   ├── mongo_mapper.rb      # MongoMapperの接続設定
│   └── mongoid.rb          # Mongoidの初期化
└── config/
    └── mongoid.yml         # Mongoidの設定ファイル
```

## 📊 検証パターン

### パターン1: 独立コレクション（安全性確認）
```
MongoMapper: MmUser → mm_users    コレクション
Mongoid:     MdUser → md_users    コレクション
```
両ODMが互いに干渉しないことを確認

### パターン2: 共有コレクション（移行シミュレーション）
```
MongoMapper: MmSharedItem → shared_items コレクション
Mongoid:     MdSharedItem → shared_items コレクション
```
**✅ 検証完了**: 同じコレクションから両ODMで読み書き可能

## 🎉 検証結果

| 項目 | 結果 | 詳細 |
|-----|------|------|  
| **ODM共存** | ✅ 成功 | 同一Rails内で両ODM正常動作 |
| **同一DB接続** | ✅ 成功 | `mongomapper_mongoid_development` |
| **共有コレクション** | ✅ 成功 | 相互データアクセス可能 |
| **段階的移行** | ✅ 実証済み | 機能単位での移行が現実的 |

## 🔌 API エンドポイント

### 基本
- `GET /` - システム状態確認

### 独立コレクションテスト  
- `POST /mm_users` - MongoMapper でユーザー作成
- `POST /md_users` - Mongoid でユーザー作成
- `GET /users` - 両ODMからユーザー一覧取得

### 共有コレクションテスト（段階的移行）
- `POST /mm_shared_items` - MongoMapper で items 作成
- `POST /md_shared_items` - Mongoid で items 作成  
- `GET /shared_items` - **両ODMから同じデータ参照**

## 🚀 セットアップ & 起動

### 前提条件
- Ruby 3.3.5
- Docker (MongoDB用)

### 手順
```bash
# 1. MongoDB起動
docker run --name mongodb-test -p 27017:27017 -d mongo:latest

# 2. 依存関係インストール
bundle install

# 3. サーバー起動
rails server
```

## 🧪 検証コマンド

### Step 1: 独立コレクションテスト
```bash
# MongoMapper でユーザー作成
curl -X POST http://localhost:3000/mm_users \
  -H "Content-Type: application/json" \
  -d '{"name":"MM User","email":"mm@test.com","age":25}'

# Mongoid でユーザー作成  
curl -X POST http://localhost:3000/md_users \
  -H "Content-Type: application/json" \
  -d '{"name":"MD User","email":"md@test.com","age":30}'

# 両方のユーザーを確認
curl http://localhost:3000/users | jq
```

### Step 2: 段階的移行シミュレーション
```bash
# 🔴 移行前: MongoMapper で既存データ作成
curl -X POST http://localhost:3000/mm_shared_items \
  -H "Content-Type: application/json" \
  -d '{"title":"Legacy Item","price":99.99}'

# 🟡 移行中: Mongoid で新機能データ作成
curl -X POST http://localhost:3000/md_shared_items \
  -H "Content-Type: application/json" \
  -d '{"title":"New Feature","price":149.99}'

# 🟢 検証: 両ODMから同じコレクションを参照
curl http://localhost:3000/shared_items | jq

# 期待結果: MongoMapper作成データとMongoid作成データが両方表示される
```

## ⚖️ 移行における考慮点

### ✅ 実現可能
| 項目 | 詳細 |
|-----|------|
| **共有コレクション** | 両ODMが同じコレクションに安全に読み書き |
| **相互データアクセス** | MongoMapper↔Mongoid でデータ相互参照 |
| **機能単位移行** | リスクを抑えた段階的な機能移行 |
| **データ整合性** | MongoDB ACID特性による一貫性保証 |

### ⚠️ 注意点
| 制限事項 | 対策 |
|---------|------|
| **ODM固有フィールド** | `updated_at`等は相手側で`null`表示 |
| **バリデーション独立** | 両ODMでルール統一が必要 |
| **関連付け不可** | 異なるODM間の`belongs_to`等は使用不可 |
| **インデックス重複** | 各ODMが独自管理するため要注意 |

## 🗺️ 推奨移行ロードマップ

```
Phase 1: 環境準備
├── 両ODM同一DB設定
├── 共有コレクション設計
└── CI/CDパイプライン調整

Phase 2: 並行開発期間  
├── 🔴 既存機能: MongoMapper維持
├── 🟢 新機能: Mongoid採用
└── 📊 相互運用性検証

Phase 3: 段階的移行
├── 機能A → Mongoid移行
├── 機能B → Mongoid移行  
└── 📈 移行状況監視

Phase 4: 完全移行
├── MongoMapper依存除去
├── 設定クリーンアップ
└── 🎉 移行完了
```

## 📈 まとめ

### 🎯 プロジェクトで実証できたこと
- ✅ MongoMapper と Mongoid の **共存可能性**
- ✅ 同一コレクションでの **相互データアクセス**  
- ✅ プロダクション環境での **段階的移行の現実性**

### 💡 実用化への提案
1. **小さく始める**: 新機能から Mongoid を採用
2. **監視強化**: ODM間のデータ整合性を継続監視  
3. **段階実行**: 機能単位で計画的に移行実施
4. **ロールバック準備**: 問題発生時の切り戻し手順整備

**結論**: MongoMapper から Mongoid への段階的移行は技術的に実現可能であり、リスクを最小化してプロダクションで実行できる移行戦略です。
