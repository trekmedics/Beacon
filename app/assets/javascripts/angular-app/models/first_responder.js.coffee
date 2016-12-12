angular
  .module('App')
  .factory('FirstResponder', ['$resource', '$http', ($resource, $http) ->
    FirstResponder = $resource('/api/v1/first_responders/:id', { id: '@id' }, {
      update: {
        method: 'PUT'
      }
    })

    FirstResponder.prototype.deletedStatus = () ->
      if this.state == 'disabled'
        return 'disabled'
      else
        return 'active'

    FirstResponder.prototype.loggedIn = () ->
      return this.state != 'inactive'

    FirstResponder.prototype.logIn = () ->
      $http.post("/api/v1/first_responders/#{this.id}/log_in")

    FirstResponder.prototype.logOut = () ->
      $http.post("/api/v1/first_responders/#{this.id}/log_out")

    FirstResponder.prototype.sendMessage = (message) ->
      $http.post("/api/v1/first_responders/#{this.id}/message", { message: message })
        .success((data, status, headers, config) ->
          if data.success == false
            alert(data.message)
        )

    FirstResponder.prototype.toggleShow = () ->
      this.isExpanded = false if !this.isExpanded?
      this.isExpanded = !this.isExpanded

    FirstResponder.prototype.expanded = () ->
      return this.isExpanded

    return FirstResponder
  ])
