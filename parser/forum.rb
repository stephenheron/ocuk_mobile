require "rubygems"
require "bundler/setup"

require "nokogiri"
require 'open-uri'
require './parser/forum_thread'

class Forum
  attr_reader :id, :title, :description, :viewing_count
  def initialize(params)
    @id = params[:id]
    @title = params[:title]
    @description = params[:description]
    @viewing_count = params[:viewing_count]
  end

  def self.load_forum(id, page)
   if page.nil?
      forum_url = "http://forums.overclockers.co.uk/forumdisplay.php?f=#{id}"
    else
      forum_url = "http://forums.overclockers.co.uk/forumdisplay.php?f=#{id}&page=#{page}"
    end
    doc = Nokogiri::HTML(open(forum_url))
  end

  def self.sub_forums(doc)
    return nil if doc.css('div > div > div > .tborder')[2].nil?
    sub_forums = self.parse_forum_list(doc.css('div > div > div > .tborder')[2].css('tr > .alt1Active'))
  end

  def self.parse_forum_list(forum_list)
     forums = Array.new
     forum_list.each do |forum_html|
      forum_link = forum_html.css('div > a')
        if !forum_link.css('strong').empty?
          forum_id = forum_html.to_s.match(/f=\d+">/).to_s.match(/\d+/)
          forum_title = forum_link.first.content
        end

      description_url = forum_html.css('.smallfont')

      if description_url[1].nil?
        forum_description = description_url[0].content
        viewing_count = 0
      else
        viewing_count = description_url[0].content
        forum_description = description_url[1].content
      end

      forum = Forum.new(:id => forum_id, :title => forum_title, :viewing_count => viewing_count, :description => forum_description)
      forums.push(forum)
     end
     return forums
  end

  def self.threads(doc, id)
    threads = Array.new

    page_title = doc.css('head > title')[0].content
    doc.css("#threadbits_forum_#{id} > tr").each do |row|
      title_html =  row.css('td')[2]
      last_post_html = row.css('td')[3]
      views_html = row.css('td')[5]
      replies_html = row.css('td')[4]


      title = title_html.css('a')[0].content
      id = title_html.css('a')[0].attributes['href'].value.match('&t=\d+').to_s.match('\d+').to_s.to_i
      poster_username = title_html.css('div')[1].css('span')[0].content
      if poster_username == ''
        #Thread with rating
        poster_username = title_html.css('div')[1].css('span')[1].content
      end
      number_of_replies = replies_html.content
      number_of_views = views_html.content

      title_html.content.match('Important Stuff:') ? sticky = true : sticky = false
      title_html.content.match('Moved:') ? moved = true : moved = false
        begin 
          if !moved
            newest_page_id = last_post_html.css('div > a').first['href'].match('&p=\d+').to_s.match('\d+').to_s 
          end
        rescue NoMethodError
          #Rescue when a thread has been moved. 
        end
        thread = ForumThread.new(:id => id, :title => title, :poster_username => poster_username, :number_of_replies => number_of_replies, :number_of_views => number_of_views, :newest_page_id => newest_page_id, :moved => moved, :sticky => sticky)
        threads.push(thread)
    end
    result = {:page_title => page_title, :threads => threads}
  end
end
