class SubcategoriesController < AdministrativeInterfaceController
  before_action :set_category
  before_action :set_subcategory, only: [:edit, :update, :destroy]

  # GET /subcategories/new
  def new
    @subcategory = Subcategory.new(category: @category)
  end

  # GET /subcategories/1/edit
  def edit
  end

  # POST /subcategorys
  def create
    @subcategory = Subcategory.new(subcategory_params.merge(category: @category))
    if @subcategory.save
      redirect_to categories_path, notice: I18n.t('activerecord.notices.models.subcategory.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /subcategories/1
  def update
    if @subcategory.update(subcategory_params)
      redirect_to categories_path, notice: I18n.t('activerecord.notices.models.subcategory.success.update')
    else
      render :edit
    end
  end

  # DELETE /subcategories/1
  def destroy
    @subcategory.destroy
    redirect_to categories_path, notice: I18n.t('activerecord.notices.models.subcategory.success.destroy')
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find_by(id: params[:category_id])
  end

  def set_subcategory
    @subcategory = Subcategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subcategory_params
    return self.params.require(:subcategory).permit(:name)
  end
end
