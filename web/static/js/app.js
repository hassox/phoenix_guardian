import {Socket} from "phoenix"

function appendToOutput(direction, label, obj) {
  var dir = direction === "in" ? "->" : "<-",
      html;
  var outPut = jQuery('#ping-output');

  html = "<li><span class='label label-success'>" + dir + "</span> <span class='label label-info'>" + label + "</span><pre>" + JSON.stringify(obj) + "</pre></li>";
  console.log(html)
  console.log(outPut);
  outPut.prepend(html);
}

let socket = new Socket("/ws");
socket.connect();

let guardianToken = jQuery('meta[name="guardian_token"]').attr('content');
let csrfToken = jQuery('meta[name="csrf_token"]').attr('content');

let chan = socket.chan("pings", { guardian_token: guardianToken, csrf_token: csrfToken });

chan.join().receive("ok", obj => {
  console.log("IN", obj)
  appendToOutput("in", "join", obj);

  setInterval(() => {
    console.log("PINGING");
    chan.push("ping", {});
    appendToOutput("out", "ping", {});
  }, 1000);

}).receive("error", obj => {
  console.log("ERROR", obj)
  appendToOutput("in", "error", obj);
});

chan.on("pong", msg => {
  console.log("PONGING");
  appendToOutput("in", "pong", msg);
});

let App = {
}

export default App
