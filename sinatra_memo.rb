# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)
require 'sinatra/reloader'
require 'json'

MEMOS_FILE = 'memos.json' # ファイルパスを変更しやすくするために定数化している

def load_memos
  JSON.parse(File.read(MEMOS_FILE)) # 変数のスコープを最低限にするため、代入処理は含めていない
rescue StandardError
  []
end

def save_memos(memos)
  File.write(MEMOS_FILE, JSON.pretty_generate(memos))
end

def assign_memos_element(memo_id)
  memos = load_memos[memo_id.to_i]
  @index = memo_id
  @memo_title = memos['title']
  @memo_body = memos['body']
end

get '/' do
  @memos = load_memos
  erb :top
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = load_memos
  memo = { title: params[:title], body: params[:body] }
  memos << memo
  save_memos(memos)
  redirect to('/')
end

get '/memos/:id/edit' do
  assign_memos_element(params[:id])
  erb :edit
end

get '/memos/:id' do
  assign_memos_element(params[:id])
  erb :show
end

delete '/memos/:id' do
  memos = load_memos
  memos.delete_at(params[:id].to_i)
  save_memos(memos)
  redirect to('/')
end

patch '/memos/:id' do
  memos = load_memos
  memo = { title: CGI.escapeHTML(params[:title]), body: CGI.escapeHTML(params[:body]) }
  memos[params[:id].to_i].replace(memo)
  save_memos(memos)
  redirect to("/memos/#{params[:id]}")
end

not_found do
  erb :not_found
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
