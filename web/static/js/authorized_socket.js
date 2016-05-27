import {Socket} from "deps/phoenix/web/static/js/phoenix";

const authSocket = new Socket("/socket");
authSocket.connect();


const token = $('meta[name="guardian_token"]').attr('content');
const channel = authSocket.channel("authorized:lobby", {guardian_token: token});
channel.join()
        .receive("ok", resp => {
          socketTalk(resp.message);
        })
        .receive("error", resp => {
          socketTalk(resp.error);
        });

channel.on("shout", data => { socketTalk(data.body, data.from); });

const socketTalk = (message, from) => {
  var out = '<li>';
  if (from) {
    out += `<span class='chat-from'>${from}:&nbsp;</span>`;
  }
  out += message;
  out += '</li>';

  $('#socket-talk').append(out);
};

const sendMessage = (e) => {
  e.preventDefault();
  let message = e.target.message.value;
  e.target.message.value = "";
  channel.push("shout", {body: message});
};

export default sendMessage;
