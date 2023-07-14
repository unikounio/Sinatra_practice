# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)
require 'sinatra/reloader'
require 'json'
require 'cgi/util'

MEMOS_FILE = 'memos.json' # ファイルパスを変更しやすくするために定数化している

def load_memos
  JSON.parse(File.read(MEMOS_FILE)) # 変数のスコープを最低限にするため、代入処理は含めていない
rescue StandardError
  []
end

def save_memos(memos)
  File.write(MEMOS_FILE, JSON.pretty_generate(memos))
end

def assign_memos_element(index)
  memos = load_memos[index.to_i]
  @index = index
  @memo_title = memos['title']
  @memo_body = memos['body']
end

get '/' do
  @memos = load_memos
  erb :top
end

get '/new' do
  erb :new
end

post '/new' do
  memos = load_memos
  memo = { title: CGI.escapeHTML(params[:title]), body: CGI.escapeHTML(params[:body]) }
  memos << memo
  save_memos(memos)
  redirect to('/')
end

get '/memos/*/edit' do |index|
  assign_memos_element(index)
  erb :edit
end

get '/memos/*' do |index|
  assign_memos_element(index)
  erb :show
end

delete '/memos/*' do |index|
  memos = load_memos
  memos.delete_at(index.to_i)
  save_memos(memos)
  redirect to('/')
end

patch '/memos/*' do |index|
  memos = load_memos
  memo = { title: CGI.escapeHTML(params[:title]), body: CGI.escapeHTML(params[:body]) }
  memos[index.to_i].replace(memo)
  save_memos(memos)
  redirect to("/memos/#{index}")
end

not_found do
  erb :not_found
end
