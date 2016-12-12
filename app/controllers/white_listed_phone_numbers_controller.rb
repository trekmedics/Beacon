class WhiteListedPhoneNumbersController < AdministrativeInterfaceController
  before_action :set_white_listed_phone_number, only: [:edit, :update, :destroy]

  # GET /white_listed_phone_numbers
  def index
    @white_listed_phone_numbers = WhiteListedPhoneNumber.by_data_center(current_user.data_center).all
  end

  # GET /white_listed_phone_numbers/new
  def new
    @white_listed_phone_number = WhiteListedPhoneNumber.new(data_center: current_user.data_center)
  end

  # GET /white_listed_phone_numbers/1/edit
  def edit
  end

  # POST /white_listed_phone_numbers
  def create
    @white_listed_phone_number = WhiteListedPhoneNumber.new(white_listed_phone_number_params.merge(data_center: current_user.data_center))
    if @white_listed_phone_number.save
      redirect_to white_listed_phone_numbers_path, notice: 'White listed phone number was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /white_listed_phone_numbers/1
  def update
    if @white_listed_phone_number.update(white_listed_phone_number_params)
      redirect_to white_listed_phone_numbers_path, notice: 'White listed phone number was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /white_listed_phone_numbers/1
  def destroy
    @white_listed_phone_number.destroy
    redirect_to white_listed_phone_numbers_path, notice: 'White listed phone number was successfully destroyed.'
  end

private

  def set_white_listed_phone_number
    @white_listed_phone_number = WhiteListedPhoneNumber.by_data_center(current_user.data_center).find_by(id: params[:id])
  end

  def white_listed_phone_number_params
    return self.params.require(:white_listed_phone_number).permit(:phone_number, :name)
  end
end
