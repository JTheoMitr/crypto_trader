class CryptocoinsController < ApplicationController

    def index
        @cryptocoins = Cryptocoin.search(params[:search])
    end

    def show
        @cryptocoin = Cryptocoin.find_by(id: params[:id])
    end

    def alphabetize
        @cryptocoins = Cryptocoin.all.alphabetize
    end

end