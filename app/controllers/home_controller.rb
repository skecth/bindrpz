class HomeController < ApplicationController
  def index
    @feed= Feed.all
  end
end
