require 'bundler/setup'
Bundler.require(:default)
require 'json'
require 'sinatra/reloader'

MEMOS_FILE = 'memos.json' # ファイルパスを変更しやすくするために定数化している

def load_memos
  JSON.parse(File.read(MEMOS_FILE)) rescue [] # 変数のスコープを最低限にするため、代入処理は含めていない
end

def save_memos(memos)
  File.write(MEMOS_FILE, JSON.pretty_generate(memos))
end

def assign_memos_element(index)
  memos = load_memos[index.to_i]
  @index = index
  @memo_title = memos["title"]
  @memo_body = memos["body"]
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
  memos = load_memos
  memo = { title: params[:title], body: params[:body] }
  memos << memo
  save_memos(memos)
  redirect to('/')
end

# メモ閲覧
get '/show/*' do |index|
  assign_memos_element(index)
  erb :show, layout: :layout
end

# メモ編集
get '/edit/*' do |index|
  assign_memos_element(index)
  erb :edit, layout: :layout
end

patch '/edit/*' do |index|
  memos = load_memos
  memo = { title: params[:title], body: params[:body] }
  memos[index.to_i].replace(memo)
  save_memos(memos)
  redirect to("/show/#{index}")
end

# メモ削除
delete '/delete/*' do |index|
  memos = load_memos
  memos.delete_at(index.to_i)
  save_memos(memos)
  redirect to('/')
end
