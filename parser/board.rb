require "rubygems"
require "bundler/setup"

require "nokogiri"
require 'open-uri'
require './parser/forum'

class Board
  @board_url = 'http://forums.overclockers.co.uk/'

  def self.boards
    forums = Hash.new

    latest_news = Array.new
    hardware = Array.new
    apple = Array.new
    software = Array.new
    audio_visual = Array.new
    games = Array.new
    life = Array.new
    distributed_computing = Array.new
    members_market = Array.new
    ocuk_matters = Array.new
    archives = Array.new
    others = Array.new
  
    doc = Nokogiri::HTML(open(@board_url))
    forum_list = Forum.parse_forum_list(doc.css('.alt1Active'))
    forum_list.each do |forum|
      case forum.title
        when "Latest News, Deals & Special Offers"
          latest_news.push(forum)
        when "General Hardware","CPUs","Overclocking & Cooling","Motherboards","Memory","Graphics Cards","Monitors","Hard Drives","Optical Storage & Writing","Sound City","Networks & Internet Connectivity","Case Central","Small Form Factor","Laptops & PDAs","Servers and Enterprise Solutions"
          hardware.push(forum)
        when "Apple Hardware","Apple Software"
          apple.push(forum)
        when "Windows & Other Software","Linux & Open Source","HTML, Graphics & Programming"
          software.push(forum)
        when "Home Cinema & Hi-Fi","Photography & Video" 
          audio_visual.push(forum)
        when "PC Games","Console Games & Hardware"
          games.push(forum)
        when "General Discussion","New Members","Speaker's Corner","Motors","La Cuisine","Sports Arena","On the Water","Music, Box Office, TV & Books","Mobile Phones","Testing"
          life.push(forum)
        when "Team OcUK Distributed Computing Projects"
          distributed_computing.push(forum)
        when "For Sale","Wanted","Price Checks"
          members_market.push(forum)
        when "OcUK Customer Service","OcUK New Product Suggestions","OcUK Jobs","OcUK Reviews"
          ocuk_matters.push(forum)
        when "Archive Forums"
          archives.push(forum)
        else
          others.push(forum)
      end
    end

    forums = {"Latest News" => latest_news, "Hardware" => hardware, "Apple" => apple, "Software" => software, "Audio Visual" => audio_visual, "Games" => games, "Life" => life, "Distributed Computing" => distributed_computing, "Members Market" => members_market, "OcUK Matters" => ocuk_matters, "Archives" => archives, "Others" => others}
    return forums
  end
end
