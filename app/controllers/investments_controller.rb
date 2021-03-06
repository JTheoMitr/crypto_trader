class InvestmentsController < ApplicationController
    before_action :set_investment, :redirect_if_not_owner, only: [:show, :edit, :update, :destroy]


    def new
      if !!current_user && params[:cryptocoin_id] && @cryptocoin = Cryptocoin.find_by_id(params[:cryptocoin_id])
        @investment = @cryptocoin.investments.build
      elsif !current_user
        redirect_to '/login', alert: "Must Be Logged In to Perform Action"
      else
        @investment = Investment.new
      end
    end    

    def create
        @investment = current_user.investments.build(investment_params)
        if (@investment.amount > current_user.wallet)
          redirect_to new_investment_path, alert: "Insufficient Balance"
        elsif @investment.save
          
          current_user.update(wallet: (current_user.wallet - @investment.amount))
          @investment.update(yield: @investment.crypto_yield)
          redirect_to investment_path(@investment)
          
        else
          render :new
        end
    end

    def index
      if params[:cryptocoin_id] && @cryptocoin = Cryptocoin.find_by_id(params[:cryptocoin_id])
        @investments = @cryptocoin.investments.where(user: current_user).ordered_by_amount
      elsif !current_user
        redirect_to '/login', alert: "Must Be Logged In to Perform Action"
      else
        @investments = current_user.investments.ordered_by_amount
      end
    end

    def show
      
    end

    def edit
      
    end

    def update
      @investment.update(investment_params)
      redirect_to investment_path(@investment)
    end

    def destroy
      @investment.destroy
      current_user.update(wallet: (current_user.wallet + @investment.amount))
      redirect_to cryptocoin_investments_path(@investment.cryptocoin.id)
    end

    def destroy_all
      if params[:cryptocoin_id] && @cryptocoin = Cryptocoin.find_by_id(params[:cryptocoin_id])
        @investments = @cryptocoin.investments.where(user: current_user)
      else
        @investments = Investment.all
      end
        current_user.update(wallet: (current_user.wallet + @investments.sum(:amount)))
        @investments.destroy_all
        redirect_to new_investment_path
    end

  

private

  def investment_params
    params.require(:investment).permit(:amount, :yield, :cryptocoin_id, cryptocoin_attributes: [:name])
  end

  def redirect_if_not_owner
    if !current_user
      redirect_to '/login', alert: "Must Be Logged In to Perform Action"
    elsif current_user != @investment.user
      redirect_to user_path(current_user), alert: "Unauthorized; No Access to Foreign Investments"
    end
  end

  def set_investment
    @investment = Investment.find(params[:id])
  end

end
