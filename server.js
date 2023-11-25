require("dotenv").config();
const { App } = require("@slack/bolt");
const express = require("express");
const app = express();
const zkcrushRegex = /\b[A-Fa-f0-9]{64}\b/;
const bolt = new App({
  token: process.env.SLACK_BOT_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET,
});

app.get("/", (req, res) => {
  res.redirect("https://crushabuse.xyz");
});
app.get("/api/check/:hash", async (req, res) => {
  const hash = req.params.hash;
  res.set("Access-Control-Allow-Origin", "*");
  if (!zkcrushRegex.test(hash)) return res.send("bad hash.").status(400);
  var urls = [];
  function notok() {
    return res.json({ ok: "no" });
  }
  async function pull(page = 1) {
    const messages = await bolt.client.search.messages({
      query: `https://zkcrush.xyz/crush?hash=${hash}`,
      count: 100,
      page,
    });
    if (!messages.ok) return notok();
    messages.messages.matches.forEach((message) => {
      if (message.text.includes(hash))
        urls.push({
          permalink: message.permalink,
          date: Math.floor(message.ts),
        });
    });
    if (messages.messages.pagination.page_count != page) pull(page + 1);
  }
  await pull(1);
  res.json(urls);
});
app.get("/api/check/:hash/:ts", async (req, res) => {
  const hash = req.params.hash;
  const ts = req.params.ts;
  res.set("Access-Control-Allow-Origin", "*");
  if (!zkcrushRegex.test(hash)) return res.send("bad hash.").status(400);
  if (!ts) return res.send("bad ts.").status(400);
  var urls = [];
  function notok() {
    return res.json({ ok: "no" });
  }
  async function pull(page = 1) {
    const messages = await bolt.client.search.messages({
      query: `https://zkcrush.xyz/crush?hash=${hash}`,
      count: 100,
      page,
    });
    if (!messages.ok) return notok();
    messages.messages.matches.forEach((message) => {
      if (message.text.includes(hash)) {
        if (message.ts > ts)
          urls.push({
            permalink: message.permalink,
            date: Math.floor(message.ts),
          });
      }
    });
    if (messages.messages.pagination.page_count != page) pull(page + 1);
  }
  await pull(1);
  res.json(urls);
});
let server = app.listen(3000, () => {
  console.log(`crushabuse app listening on port ${server.address().port}`);
});
