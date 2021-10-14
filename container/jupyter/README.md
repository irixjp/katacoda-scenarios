# AITAC インフラ自動化演習用 Jupyter Lab コンテナ

## Build

``` bash
ANSIBLE_VERSION=2.11.5

docker build -t irixjp/aitac-automation-jupyter:${ANSIBLE_VERSION:?} .
docker login
docker push irixjp/aitac-automation-jupyter:${ANSIBLE_VERSION:?} .
```

## Usage

```bash
ANSIBLE_VERSION=2.11.5

docker run -d -p 8888:8888 --name aitac -e PASSWORD=password \
           -v /var/run/docker.sock:/var/run/docker.sock \
           irixjp/aitac-automation-jupyter:${ANSIBLE_VERSION:?}
```

- アクセス方法 http://<サーバーのIP>:8888/
- ここで設定したパスワードでログイン可能（ユーザー名は無し）

