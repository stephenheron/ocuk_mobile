require 'sinatra'
require './parser/board'
require './parser/forum'
require './parser/forum_thread'

get '/' do
  @page_title = 'Home'
  @boards = Board.boards
  erb :index
end

get '/forum/:id' do
  doc = Forum.load_forum(params[:id], nil)
  result = Forum.threads(doc, params[:id])
  @sub_forums = Forum.sub_forums(doc)
  @id = params[:id]
  @page_title = result[:page_title]
  @threads = result[:threads]
  erb :forum
end

get '/forum/:id/page/:page' do
  doc = Forum.load_forum(params[:id], params[:page])
  result = Forum.threads(doc, params[:id])
  @sub_forums = Forum.sub_forums(doc)
  @id = params[:id]
  @page = params[:page]
  @page_title = result[:page_title]
  @threads = result[:threads]
  erb :forum
end

get '/thread/:id' do
  doc = ForumThread.load_thread(params[:id], nil, false)
  @posts = ForumThread.posts(doc)
  @thread_information = ForumThread.thread_information(doc)
  @page_title = @thread_information[:title]
  erb :thread
end

get '/thread/:id/reply' do
    redirect "http://forums.overclockers.co.uk/newreply.php?do=newreply&noquote=1&p=#{params[:id]}"
end

get '/thread/:id/full' do
    redirect "http://forums.overclockers.co.uk/showthread.php?t=#{params[:id]}"
end

get '/thread/:id/last' do
  doc = ForumThread.load_thread(params[:id], nil, true)
  @posts = ForumThread.posts(doc)
  @thread_information = ForumThread.thread_information(doc)
  @page_title = @thread_information[:title]
  erb :thread
end


get '/thread/:id/page/:page' do
  doc = ForumThread.load_thread(params[:id], params[:page], false)
  @posts = ForumThread.posts(doc)
  @thread_information = ForumThread.thread_information(doc)
  @page_title = @thread_information[:title]
  erb :thread
end

