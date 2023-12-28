class ApplicationController < ActionController::Base
	before_action :authenticate_user!, except: [:new, :create]

	def application
		@id = Feed.first.id
		puts "id#{@id}"
	end

	private 

	def authenticate_user!
		if user_signed_in?
      super
    else
      redirect_to new_user_session_path, notice: 'Please sign in.'
    end
	end



end
