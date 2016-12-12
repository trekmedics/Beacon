class IncidentsController < AdministrativeInterfaceController
  # GET /incidents
  def index
    @incidents = Incident.by_data_center(current_user.data_center).all.order(id: :desc)
  end

  # GET /incidents/1
  def show
    @incident = Incident.by_data_center(current_user.data_center).find_by(id: params[:id]) if Rails.env.development?
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
    @categories = Category.all
  end

  # POST /incidents
  def create
    @incident = IncidentManager.instance.handle_admin_created_incident(
      current_user.data_center,
      incident_params[:help_message],
      incident_params[:location],
      incident_params[:number_of_frs_to_allocate],
      incident_params[:number_of_transport_vehicles_to_allocate],
      incident_params[:subcategory_id]
    )
    if @incident.valid?
      redirect_to @incident, notice: I18n.t('activerecord.notices.models.incident.success.create')
    else
      render :new
    end
  end

private

  def incident_params
    return self.params.require(:incident).permit(
    :help_message,
    :location,
    :number_of_frs_to_allocate,
    :number_of_transport_vehicles_to_allocate,
    :subcategory_id
    )
  end
end
