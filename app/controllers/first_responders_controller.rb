class FirstRespondersController < AdministrativeInterfaceController
  before_action :set_first_responder, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /first_responders
  def index
    @first_responders = FirstResponder.by_data_center(current_user.data_center).where.not(state: 0).order(:name)
  end

  # GET /first_responders/1
  def show
    @first_responder_report = FirstResponderReport.new(@first_responder)
  end

  # GET /first_responders/new
  def new
    @first_responder = FirstResponder.new
  end

  # GET /first_responders/1/edit
  def edit
  end

  # POST /first_responders
  def create
    @first_responder = FirstResponder.new(first_responder_params.merge(data_center: current_user.data_center))
    if @first_responder.save
      redirect_to @first_responder, notice: I18n.t('activerecord.notices.models.first_responder.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /first_responders/1
  def update
    if @first_responder.update(first_responder_params)
      redirect_to @first_responder, notice: I18n.t('activerecord.notices.models.first_responder.success.update')
    else
      render :edit
    end
  end

  # DELETE /first_responders/1
  def destroy
    @first_responder.soft_delete
    redirect_to first_responders_url, notice: I18n.t('activerecord.notices.models.first_responder.success.destroy')
  end

private

  def set_first_responder
    @first_responder = FirstResponder.by_data_center(current_user.data_center).find_by_id(params[:id])
  end

  def first_responder_params
    return self.params.require(:first_responder).permit(:name, :phone_number, :locale)
  end
end
