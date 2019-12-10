#!/bin/sh

# 当发生错误时中止脚本
set -e

rm -rf dist

# 构建
yarn generate

# cd 到构建输出的目录下
cd dist

git init
git add -A
git commit -m 'deploy'

git push -f git@git.dev.tencent.com:hsocode/tenai-blog.git master

cd -
