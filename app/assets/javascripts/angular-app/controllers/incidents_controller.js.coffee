angular
  .module('App')
  .controller 'IncidentCtrl', ['$scope', 'Incident', 'Config', ($scope, Incident, Config) ->
    $scope.incidents = Incident.query()

    $scope.cancelIncident = (incident) ->
      cancelReason = prompt('Are you sure you want to cancel this incident?  Reason:')
      console.log('Cancel Reason: ', cancelReason)
      if cancelReason? && cancelReason != ''
        incident.cancel(cancelReason)

    dispatcher = new WebSocketRails(Config.websocket_url)

    dispatcher.on_open = (data) ->
      console.log('Connection has been established (IncidentCtrl): ', data)

    channel = dispatcher.subscribe('incident')

    channel.bind('create', (data) ->
      console.log('Got new incident from server: ', data)
      $scope.$apply ->
        $scope.incidents.unshift(new Incident(data))
    )

    channel.bind('update', (data) ->
      console.log('Got updated incident from server: ', data)
      for incident in $scope.incidents
        if incident.id == data.id
          $scope.$apply ->
            incident.state = data.state
            incident.state_string = data.state_string
            incident.help_message = data.help_message
            incident.location = data.location
            incident.incident_commander = data.incident_commander
            incident.created_at_string = data.created_at_string
            incident.updated_at_string = data.updated_at_string
    )
  ]
