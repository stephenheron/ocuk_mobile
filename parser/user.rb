class User
  attr_reader :id, :username, :title, :joined, :post_count, :location

    def initialize(params)
      @id = params[:id]
      @username = params[:username]
      @title = params[:title]
      @joined = params[:joined]
      @post_count = params[:post_count]
      @location = params[:location]
  end
end
