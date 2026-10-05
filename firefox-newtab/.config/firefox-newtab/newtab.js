const days = ["yakshanba","dushanba","seshanba","chorshanba","payshanba","juma","shanba"];
const months = ["yanvar","fevral","mart","aprel","may","iyun","iyul","avgust","sentabr","oktabr","noyabr","dekabr"];

function tick() {
  const d = new Date();
  const pad = n => String(n).padStart(2, "0");
  document.getElementById("time").textContent = `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  document.getElementById("date").textContent =
    `${d.getDate()}-${months[d.getMonth()]}, ${days[d.getDay()]}`;
}
tick();
setInterval(tick, 1000);
