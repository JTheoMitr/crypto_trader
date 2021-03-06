class UsersController < ApplicationController

    def new
        @user = User.new
    end 

    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id] = @user.id
            redirect_to user_path(@user)
        else
            flash[:message] = @user.errors.full_messages.join(", ")
            render :new
        end
    end

    def show
        @user = User.find(params[:id])
    end

    def update
        @user.update(user_params)
    end

    private
    
    def user_params
        params.require(:user).permit(:username, :email, :password, :wallet)
    end


end
