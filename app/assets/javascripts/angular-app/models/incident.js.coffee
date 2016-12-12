angular
  .module('App')
  .factory('Incident', ['$resource', '$http', ($resource, $http) ->
    Incident = $resource('/api/v1/incidents/:id', { id: '@id' }, { 
      update: {
        method: 'PUT'
      }
    })

    Incident.prototype.cancel = (newComment) ->
      $http.post("/api/v1/incidents/#{this.id}/cancel_incident", { comment: newComment })

    Incident.prototype.can_cancel = () ->
      return this.state != 'incident_complete'

    Incident.prototype.message_log_present = () ->
      return this.formatted_message_log && this.formatted_message_log.length > 0

    Incident.prototype.canSimulate = () ->
      return this.state != 'incident_complete'

    Incident.prototype.send_message = (phone_number, message) ->
      if message? and message.length > 0
        $http.post('/api/v1/incoming_messages', { From: phone_number, Body: message })

    Incident.prototype.send_admin_reporting_party_message = (message) ->
      if message? and message.length > 0
        $http.post('/api/v1/incoming_messages/admin_reporting_party', { incident_id: this.id, message: message })

    Incident.prototype.reportingPartyString = () ->
      if this.reporting_party?
        if this.reporting_party.is_admin
          return 'Web Admin'
        else
          return this.reporting_party.phone_number
      return ''

    Incident.prototype.editComment = (newComment) ->
      if newComment? and newComment.length > 0
        $http.post("/api/v1/incidents/#{this.id}/edit_comment", { comment: newComment })

    return Incident
  ])
