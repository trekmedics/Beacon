angular
  .module('App')
  .controller 'FirstResponderCtrl', ['$scope', 'FirstResponder', 'Config', ($scope, FirstResponder, Config) ->
    $scope.firstResponders = FirstResponder.query()

    $scope.messageFirstResponder = (firstResponder) ->
      firstResponder.sendMessage(firstResponder.message)
      firstResponder.message = null

    dispatcher = new WebSocketRails(Config.websocket_url)

    dispatcher.on_open = (data) ->
      console.log('Connection has been established (FirstResponderCtrl): ', data)

    channel = dispatcher.subscribe('first_responder')

    channel.bind('update', (data) ->
      console.log('Got message from server: ', data)
      for firstResponder in $scope.firstResponders
        if firstResponder.id == data.id
          $scope.$apply ->
            firstResponder.state = data.state
            firstResponder.state_string = data.state_string
            firstResponder.transportation_mode = data.transportation_mode
    )
  ]
