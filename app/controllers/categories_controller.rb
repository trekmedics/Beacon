class CategoriesController < AdministrativeInterfaceController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  def index
    @categories = Category.all
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)
      if @category.save
        redirect_to categories_path, notice: I18n.t('activerecord.notices.models.category.success.create')
      else
        render :new
      end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: I18n.t('activerecord.notices.models.category.success.update')
    else
      render :edit
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to categories_url, notice: I18n.t('activerecord.notices.models.category.success.destroy')
  end

private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
  return self.params.require(:category).permit(:name)
  end
end
