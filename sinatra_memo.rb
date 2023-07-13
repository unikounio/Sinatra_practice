require 'bundler/setup'
Bundler.require(:default)
require 'json'
require 'sinatra/reloader'

MEMOS_FILE = 'memos.json' # ファイルパスを変更しやすくするために定数化している

def load_memos
  JSON.parse(File.read(MEMOS_FILE)) rescue [] # 変数のスコープを最低限にするため、代入処理は含めていない
end

def add_and_save_memos
  memos = load_memos
  memo = { title: params[:title], body: params[:body] }
  memos << memo
  File.write(MEMOS_FILE, JSON.pretty_generate(memos))
end

# トップページ
get '/' do
  @memos = load_memos
  erb :top, layout: :layout
end

# 新規作成
get '/new' do
  erb :new, layout: :layout
end

post '/new' do
  add_and_save_memos
  redirect to('/')
end

# メモ閲覧
get '/show/*' do |index|
  memos = load_memos
  @memo_title = memos[index.to_i]["title"]
  @memo_body = memos[index.to_i]["body"]
  erb :show, layout: :layout
end

# メモ編集
get '/edit' do
  erb :edit, layout: :layout
end

post '/edit' do
  add_and_save_memos
  redirect to('/show')
end

# メモ削除
delete '/delete' do
end
