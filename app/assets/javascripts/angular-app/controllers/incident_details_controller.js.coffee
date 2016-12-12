angular
  .module('App')
  .controller('IncidentDetailsCtrl', ['$scope', '$location', 'Incident', 'FirstResponder', 'Config', ($scope, $location, Incident, FirstResponder, Config) ->
    incidentId = $location.absUrl().match(/(?:incidents\/)(\d+)/)[1]
    $scope.incident = Incident.get({ id: incidentId },
      (data) ->
        processMessageLog(data.formatted_message_log)
    )

    dispatcher = new WebSocketRails(Config.websocket_url)

    dispatcher.on_open = (data) ->
      console.log('Connection has been established (IncidentDetailsCtrl): ', data)

    channel = dispatcher.subscribe('incident')

    channel.bind('update', (data) ->
      if $scope.incident.id == data.id
        $scope.$apply ->
          $scope.incident.state = data.state
          $scope.incident.state_string = data.state_string
          $scope.incident.help_message = data.help_message
          $scope.incident.location = data.location
          $scope.incident.reporting_party = data.reporting_party
          $scope.incident.incident_commander = data.incident_commander
          $scope.incident.created_at_string = data.created_at_string
          $scope.incident.updated_at_string = data.updated_at_string
          $scope.incident.comment = data.comment
    )

    channel.bind('message_log', (data) ->
      if $scope.incident.id == data.incident_id
        $scope.$apply ->
          addMessageLogItem(data)
    )

    processMessageLog = (messageLog) ->
      $scope.requestedFirstResponders = []
      $scope.incidentActors = []
      $scope.messageLog = []
      for logItem in messageLog
        addMessageLogItem(logItem)

    addMessageLogItem = (logItem) ->
      switch logItem.message_type
        when 'request_for_assistance'
          $scope.requestedFirstResponders.push({ hash_key: logItem.hash_key, id: logItem.resource_id, name: logItem.resource_name, phone_number: logItem.resource_phone_number, request_message: logItem[logItem.hash_key], canSimulate: true, request_time: logItem.time })
        when 'request_for_assistance_reply'
          for requestFirstResponder in $scope.requestedFirstResponders
            if requestFirstResponder.hash_key == logItem.hash_key
              requestFirstResponder.response = logItem[logItem.hash_key]
              requestFirstResponder.canSimulate = false
              requestFirstResponder.reply_time = logItem.time

        when 'fr_not_needed'
          for requestFirstResponder in $scope.requestedFirstResponders
            if requestFirstResponder.hash_key == logItem.hash_key
              requestFirstResponder.fr_not_needed = logItem[logItem.hash_key]
              requestFirstResponder.not_needed_time = logItem.time
        else
          addIncidentActorIfNecessary(logItem)
          $scope.messageLog.push(logItem)

    addIncidentActorIfNecessary = (data) ->
      addIncidentActor = true
      for incidentActor in $scope.incidentActors
        if incidentActor.hash_key == data.hash_key
          addIncidentActor = false
      if addIncidentActor
        $scope.incidentActors.push({ hash_key: data.hash_key, id: data.resource_id, type: data.resource_type, name: data.resource_name, phone_number: data.resource_phone_number })

    $scope.messageIncidentActor = (actor) ->
      if actor.phone_number == 'Admin'
        $scope.incident.send_admin_reporting_party_message(actor.message)
      else
        $scope.incident.send_message(actor.phone_number, actor.message)
      actor.message = null

    $scope.canSimulateForIncidentActor = (actor) ->
      return actor.type == 'first_responder' || actor.type == 'reporting_party'

    $scope.assistanceResponseCount = (requestedFirstResponders) ->
      return 0 if !requestedFirstResponders?
      requestedFirstResponders.filter((x) ->
        return x.response?
      ).length

    $scope.toggleShowRequestsForAssistance = () ->
      $scope.isRequestsForAssistanceExpanded = false if !$scope.isRequestsForAssistanceExpanded?
      $scope.isRequestsForAssistanceExpanded = !$scope.isRequestsForAssistanceExpanded

    $scope.showRequestsForAssistance = () ->
      return $scope.isRequestsForAssistanceExpanded

    $scope.editComment = (incident) ->
      newComment = prompt('Enter a comment', incident.comment)
      $scope.incident.editComment(newComment)

    $scope.tableBodyClass = () ->
      if $scope.incident.canSimulate()
        return 'with_simulator'
      else
        return 'without_simulator'

  ])
