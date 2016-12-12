'use strict'

url = window.location.href
if (url.indexOf('localhost') > -1)
  ws_url = 'localhost:3001/websocket'
else
  ws_url = 'dispatch.trekmedics.org/websocket'

console.log(ws_url)
angular
  .module('App', ['ngRoute', 'ngResource'])
  .constant('Config', {
    websocket_url: ws_url
  })
