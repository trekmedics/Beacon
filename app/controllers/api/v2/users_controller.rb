module Api
  module V2
    class UsersController < ApiController
      before_action :set_user, only: [:update, :destroy]

      def index
        @users = User.all.order(id: :asc)
        render json: @users
      end

      def create
        data_center_id = params[:data_center_id] || @api_user.data_center.id
        @user = User.new(user_params.merge(data_center_id: data_center_id))
        if @user.save
          render json: @user
        else
          render json: ErrorsHelper.serialize(@user.errors), status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: ErrorsHelper.serialize(@user.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @user.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@user.errors), status: :unprocessable_entity
        end
      end

    private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        return self.params.permit(:username, :password, :password_confirmation, :locale, :user_role_id, :data_center_id)
      end
    end
  end
end
