# MongoMapper と Mongoid 共存検証

Rails 8 アプリケーションで MongoMapper と Mongoid の共存を検証するプロジェクトです。

## 環境構成

- **Ruby**: 3.3.5
- **Rails**: 8.0.2.1 (API mode)
- **MongoMapper**: 0.17.0
- **Mongoid**: 9.0.7
- **MongoDB**: Docker コンテナで稼働

## 共存戦略

両ODMの競合を避けるため、以下の戦略を採用:

1. **別々のデータベース使用**:
   - MongoMapper: `mongomapper_mongoid_development_mm`
   - Mongoid: `mongomapper_mongoid_development`

2. **別々のモデルクラス**:
   - MongoMapper: `MmUser`
   - Mongoid: `MdUser`

## テスト結果

✅ **共存成功**: 両ODMが同一Rails アプリケーション内で正常に動作することを確認

### API エンドポイント

- `GET /`: ステータス確認
- `POST /mm_users`: MongoMapper ユーザー作成
- `POST /md_users`: Mongoid ユーザー作成  
- `GET /users`: 全ユーザー一覧（両ODM）

## 起動方法

```bash
# MongoDB Docker コンテナ起動
docker run --name mongodb-test -p 27017:27017 -d mongo:latest

# Rails サーバー起動
rails server
```

## 検証コマンド例

```bash
# MongoMapper ユーザー作成
curl -X POST http://localhost:3000/mm_users \
  -H "Content-Type: application/json" \
  -d '{"name":"MM User","email":"mm@test.com","age":25}'

# Mongoid ユーザー作成
curl -X POST http://localhost:3000/md_users \
  -H "Content-Type: application/json" \
  -d '{"name":"MD User","email":"md@test.com","age":30}'

# 全ユーザー確認
curl http://localhost:3000/users
```
