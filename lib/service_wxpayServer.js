// Node.js 示例
const crypto = require("crypto");

// 生成微信支付签名
function generateSign(params, apiKey) {
  const sortedKeys = Object.keys(params).sort();
  const signStr =
    sortedKeys.map((key) => `${key}=${params[key]}`).join("&") +
    `&key=${apiKey}`;
  return crypto.createHash("md5").update(signStr).digest("hex").toUpperCase();
}

app.post("/api/wechat/prepay", async (req, res) => {
  const { orderNo, amount, orderName, openId } = req.body;

  // 1. 调用微信统一下单接口
  const unifiedOrderParams = {
    appid: "wx1234567890abcdef",
    mch_id: "1234567890",
    nonce_str: generateNonceStr(),
    body: orderName,
    out_trade_no: orderNo,
    total_fee: Math.round(amount * 100), // 分
    spbill_create_ip: req.ip,
    notify_url: "https://your-api.com/api/wechat/notify",
    trade_type: "APP",
    openid: openId,
  };

  // 签名
  unifiedOrderParams.sign = generateSign(unifiedOrderParams, "YOUR_API_KEY");

  // 2. 发送请求到微信支付
  const xml = buildXML(unifiedOrderParams);
  const response = await requestWeChatAPI(xml);
  const prepayId = response.xml.prepay_id;

  // 3. 生成APP调起支付的参数
  const payParams = {
    appId: unifiedOrderParams.appid,
    partnerId: unifiedOrderParams.mch_id,
    prepayId: prepayId,
    packageValue: "Sign=WXPay",
    nonceStr: generateNonceStr(),
    timeStamp: Math.floor(Date.now() / 1000).toString(),
  };
  payParams.sign = generateSign(payParams, "YOUR_API_KEY");

  res.json(payParams);
});
