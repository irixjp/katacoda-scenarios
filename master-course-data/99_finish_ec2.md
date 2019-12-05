# 演習環境のクリーンアップ
---
全ての演習が終わったら、演習環境を削除してください。

`cd ~/tools`{{execute}}

`ansible-playbook ec2_cleanup.yml`{{execute}}

実行が完了したら AWS のコンソールからインスタンスが削除されていることを確認してください。
