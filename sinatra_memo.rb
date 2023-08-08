# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)
require 'sinatra/reloader'
require 'pg'

configure do
  set :conn, PG.connect(dbname: 'memos')
end

def assign_memos_element(memo_id)
  memo = settings.conn.exec('SELECT * FROM memos WHERE memo_id = $1', [memo_id]).first
  @index = memo_id
  @memo_title = memo['title']
  @memo_body = memo['body']
end

get '/' do
  @memos = settings.conn.exec('SELECT * FROM memos ORDER BY memo_id ASC')
  erb :top
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memo = { title: params[:title], body: params[:body] }
  settings.conn.exec('INSERT INTO memos (title, body) VALUES ($1, $2)', [memo[:title], memo[:body]])
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
  settings.conn.exec('DELETE FROM memos WHERE memo_id = $1', [params[:id]])
  redirect to('/')
end

patch '/memos/:id' do
  memo = { title: params[:title], body: params[:body] }
  settings.conn.exec('UPDATE memos SET (title, body) = ($1, $2) WHERE memo_id = $3', [memo[:title], memo[:body], params[:id]])
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
