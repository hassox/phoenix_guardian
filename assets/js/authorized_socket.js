import { Socket } from "phoenix"

const authSocket = new Socket("/socket")
authSocket.connect()

const guardian_token = $('meta[name="guardian_token"]').attr("content")
const channel = authSocket.channel("authorized:lobby", { guardian_token })

const socketTalk = (message, from) => {
  var out = "<li>"
  if (from) {
    out += `<span class='chat-from'>${from}:&nbsp;</span>`
  }
  out += message
  out += "</li>"

  $("#socket-talk").append(out)
}
channel
  .join()
  .receive("ok", ({ message }) => socketTalk(message))
  .receive("error", ({ error }) => socketTalk(error))
channel.on("shout", ({ body, from }) => socketTalk(body, from))

const sendMessage = e => {
  e.preventDefault()
  let message = e.target.message.value
  e.target.message.value = ""
  channel.push("shout", { body: message })
}

export default sendMessage
