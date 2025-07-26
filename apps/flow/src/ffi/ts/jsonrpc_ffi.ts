import process from 'node:process'
import * as rpc from 'vscode-jsonrpc/node.js'

export function createConnection() {
  return rpc.createMessageConnection(
    new rpc.StreamMessageReader(process.stdin),
    new rpc.StreamMessageWriter(process.stdout),
  )
}

export function initialize(connection: rpc.MessageConnection, handler: any) {
  return connection.onRequest('initialize', handler)
}

export function onQuery(connection: rpc.MessageConnection, handler: any) {
  return connection.onRequest('query', handler)
}

export function onRequest(connection: rpc.MessageConnection, method: string, handler: any) {
  return connection.onRequest(method, handler)
}

export function sendRequest(connection: rpc.MessageConnection, method: string, params: any) {
  return connection.sendRequest(method, params)
}

export function listen(connection: rpc.MessageConnection) {
  connection.listen()
}
