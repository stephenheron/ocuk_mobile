class Post
  attr_reader :id, :content

    def initialize(params)
      @id = params[:id]
      @content = params[:content]
  end
end
