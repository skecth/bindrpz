class ApplicationController < ActionController::Base

    


def application
    @id = Feed.first.id
    puts "id#{@id}"
end



end
