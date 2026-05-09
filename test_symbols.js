const pptxgen = require("pptxgenjs");

let pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';

let slide = pres.addSlide();
slide.addText("符号显示测试", {
  x: 0.5, y: 0.5, w: 9, h: 0.6,
  fontSize: 32, bold: true, color: "1E3A8A"
});

// 测试1：使用Unicode下标
slide.addText("测试1 - Unicode下标：H₂(p), log₂(p)", {
  x: 0.5, y: 1.5, w: 9, h: 0.4,
  fontSize: 14, color: "334155"
});

// 测试2：使用富文本模拟上下标
slide.addText([
  { text: "测试2 - 富文本：H", options: { fontSize: 14 } },
  { text: "2", options: { fontSize: 10, color: "FF0000" } },
  { text: "(p), log", options: { fontSize: 14 } },
  { text: "2", options: { fontSize: 10, color: "FF0000" } },
  { text: "(p)", options: { fontSize: 14 } }
], {
  x: 0.5, y: 2.2, w: 9, h: 0.4
});

// 测试3：使用HTML标签（如果支持）
slide.addText("测试3 - HTML：H<sub>2</sub>(p), log<sub>2</sub>(p)", {
  x: 0.5, y: 2.9, w: 9, h: 0.4,
  fontSize: 14, color: "334155"
});

// 测试4：希腊字母
slide.addText("测试4 - 希腊字母：α β γ δ ε ζ η θ", {
  x: 0.5, y: 3.6, w: 9, h: 0.4,
  fontSize: 14, color: "334155"
});

// 测试5：数学符号
slide.addText("测试5 - 数学符号：∈ ∉ ∪ ∩ ∑ ∏ √ ∞ ≈ ≠ ≤ ≥", {
  x: 0.5, y: 4.3, w: 9, h: 0.4,
  fontSize: 14, color: "334155"
});

pres.writeFile({ fileName: "C:/Users/li/Documents/MATLAB/digital_comm_system/符号测试.pptx" })
  .then(() => {
    console.log("✅ 符号测试PPT已生成");
  })
  .catch(err => {
    console.error("❌ 生成失败：", err);
  });
