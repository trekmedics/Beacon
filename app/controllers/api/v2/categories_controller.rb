module Api
  module V2
    class CategoriesController < ApiController
      before_action :set_category, only: [:update, :destroy]

      def index
        @categories = Category.all.order(id: :asc)
        render json: @categories
      end

      def create
        @category = Category.new(category_params)
        if @category.save
          render json: @category
        else
          render json: ErrorsHelper.serialize(@category.errors), status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render json: ErrorsHelper.serialize(@category.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @category.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@category.errors), status: :unprocessable_entity
        end
      end

    private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        return self.params.permit(:name)
      end
    end
  end
end
