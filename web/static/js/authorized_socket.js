import {Socket} from "deps/phoenix/web/static/js/phoenix"

const authSocket = new Socket("/socket")
authSocket.connect()


const token = $('meta[name="guardian_token"]').attr('content')
const channel = authSocket.channel("authorized:lobby", {guardian_token: token})
        .join()
        .receive("ok", resp => { socketTalk(resp.message)})
        .receive("error", resp => { socketTalk(resp.error) })

const socketTalk = (message) => {
  $('#socket-talk') .text(message);
}

export default authSocket
