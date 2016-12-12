module Api
  module V2
    class UnregisteredPartiesController < ApiController
      def index
        @unregistered_parties = UnregisteredParty.all
        render json: @unregistered_parties
      end
    end
  end
end
