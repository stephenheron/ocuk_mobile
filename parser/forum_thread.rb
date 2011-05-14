require "rubygems"
require "bundler/setup"

require "nokogiri"
require 'open-uri'

require './parser/user'
require './parser/post'

class ForumThread
  attr_reader :id, :title, :poster_username, :number_of_replies, :number_of_views, :newest_page_id, :moved, :sticky
  def initialize(params)
    @id = params[:id]
    @title = params[:title]
    @poster_username = params[:poster_username]
    @number_of_replies = params[:number_of_replies]
    @number_of_views = params[:number_of_views]
    @newest_page_id = params[:newest_page_id]
    @moved = params[:moved]
    @sticky = params[:sticky]
  end

  def self.load_thread(id, page, last)
    if page.nil?
      if last 
        thread_url = "http://forums.overclockers.co.uk/showthread.php?p=#{id}"
      else
        thread_url = "http://forums.overclockers.co.uk/showthread.php?t=#{id}"
      end
    else
      thread_url = "http://forums.overclockers.co.uk/showthread.php?t=#{id}&page=#{page}"
    end 
    doc = Nokogiri::HTML(open(thread_url))
  end

  def self.thread_information(doc)
    thread_id = doc.css('div > div.page > div').to_s.match('<td class="alt1" nowrap><a class="smallfont" href="showthread.php\?s=\S*').to_s.scan(/;t=(\d*)/).first[0]
    thread_title = doc.css('head > title')[0].content.gsub(' - Overclockers UK Forums', '')
    page_information = doc.css('div > .page > div > table')[1].css('table > tr > td')[0]
    if page_information.nil?
      current_page = 1
      max_page = 1
    else
      pages = page_information.content.scan(/\d+/)
      current_page = pages[0]
      max_page = pages[1]
    end

    return {:id => thread_id, :title => thread_title, :current_page => current_page, :max_page => max_page}
  end
  
  def self.posts(doc)
    post_array = Array.new
    posts = doc.css('#posts > div > div')
    posts.each do |post_html|
      user_information = post_html.css('div > table > tr')[1].css('td')
      username = user_information.css('div > a')[0].content
      user_title = user_information.css('div')[1].content

      # Check if a avatar is present. If it is not set the offset to -1
      if user_information.css('td > div')[2].css('a')[0].nil?
        avatar_offset = -1
      else
        avatar_offset = 0
      end
    
      user_information_table = user_information.css('div')[3 + avatar_offset].css('div')
      user_id = user_information[0].css('div')[0].css('a').to_s.match(';u=\d*').to_s.match('\d+') 

      # Check if location is present.
      if user_information_table[1].content.match('Location')
        location_offset = 0
      else
        location_offset = -1
      end

      user_joined = user_information_table[0].content
      
      if location_offset == 0
        user_location = user_information_table[1].content
      end
     
      user_post_count = user_information_table[2 + location_offset].content.strip

      post_information = post_html.css('div > div > table > tr')[1].css('td')[1]
      post_id = post_information.attributes['id'].to_s.gsub('td_post_','')
      post_content = post_information.css("#post_message_#{post_id}")[0]
     
      #Remove quote links 
      post_content = post_content.to_s.gsub(/<a href="showthread.php\b[^>]*>.*?<\/a>/, '')

      #Replace relative links to smilies with the full path
      post_content = post_content.to_s.gsub(/<img src="images\/smilies\//,'<img src="http://forums.overclockers.co.uk/images/smilies/')
  
      user = User.new(:id => user_id, :username => username, :joined => user_joined, :location => user_location, :post_count => user_post_count) 
      post = Post.new(:id => post_id, :content => post_content)
     
      post_data = {:user => user, :post => post}
      post_array.push(post_data)
    end
  return post_array
  end
end
