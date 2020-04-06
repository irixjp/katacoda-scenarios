# Interactive Katacoda Scenarios

[![](http://shields.katacoda.com/katacoda/irixjp/count.svg)](https://www.katacoda.com/irixjp "Get your profile on Katacoda.com")

Visit https://www.katacoda.com/irixjp to view the profile and interactive scenarios

### Writing Scenarios
Visit https://www.katacoda.com/docs to learn more about creating Katacoda scenarios

For examples, visit https://github.com/katacoda/scenario-example


### 演習実績

Katacoda 上でどのくらい演習が実行されたか（最初の `setup.sh` を実行した回数）

![result-kata.png](http://18.182.66.157/result-kata.png)

> Note: たまに表示されないことがあります。

### この演習内容はAWSでも試すことができます

Katacoda は時間によっては重いので、AWS上に自分専用の環境を立ててじっくり演習することも可能です。

必要なもの

- AWS アカウント
- 最新版 docker

```bash
mkdir ~/src && cd ~/src

git clone https://github.com/irixjp/katacoda-scenarios.git

docker run -d -p 8888:8888 --name aitac -e PASSWORD=password \
-v ~/src/katacoda-scenarios/master-course-data:/jupyter/texts \
-v ~/src/katacoda-scenarios/master-course-data/assets/solutions:/jupyter/solutions \
-v ~/src/katacoda-scenarios/master-course-data/assets/working:/jupyter/working \
-v ~/src/katacoda-scenarios/master-course-data/assets/tools:/jupyter/tools \
irixjp/aitac-automation-jupyter:dev
```

上記のようにコンテナを起動して、ブラウザで `localhost:8888` へアクセスすると、 jupyter lab へアクセスできます。

`texts/00_start_here.md` を開いて、テキストの指示に従い演習を進めてください。

