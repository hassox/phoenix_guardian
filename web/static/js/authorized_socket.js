import {Socket} from "deps/phoenix/web/static/js/phoenix"

const authSocket = new Socket("/socket")
authSocket.connect()


const token = $('meta[name="guardian_token"]').attr('content')
const channel = authSocket.channel("authorized:lobby", {guardian_token: token});
channel.join()
        .receive("ok", resp => {
          console.log(resp);
          socketTalk(resp.message)
        })
        .receive("error", resp => {
          console.log(resp);
          socketTalk(resp.error)
        });

channel.on("shout", data => { socketTalk(data.body, data.from); });

const socketTalk = (message, from) => {
  var out = '<li>'
  if (from) {
    out += `<span class='chat-from'>${from}</span>`
  }
  out += message
  out += '</li>'

  $('#socket-talk').append(out);
}

export const sendMessage = (e) => {
  e.preventDefault();
  let message = e.target.message.value;
  e.target.message.value = "";
  console.log("SHOUTING", message);
  channel.push("shout", {body: message})
}

export default authSocket
