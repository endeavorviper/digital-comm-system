const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "信息论与编码实验";
pres.title  = "期末实验答辩";

// 配色：深蓝 + 浅灰，简洁专业
const C = {
  dark:    "1A1A2E",   // 深蓝黑 - 主色
  mid:     "16213E",   // 深蓝紫
  accent:  "0F3460",   // 深蓝
  blue:    "E94560",   // 亮红（点缀）
  light:   "F5F5F5",   // 浅灰背景
  white:   "FFFFFF",
  text:    "222222",
  gray:    "888888",
  line:    "DDDDDD",
};

// ===== 工具函数 =====
function addSlide(bg) {
  const s = pres.addSlide();
  s.background = { color: bg || C.light };
  return s;
}

// 安全嵌入图片
function addImageSafe(slide, imgPath, opts) {
  const fs = require("fs");
  const path = require("path");
  const abs = path.resolve(imgPath);
  if (fs.existsSync(abs)) {
    slide.addImage(Object.assign({ path: abs }, opts));
  } else {
    slide.addShape(pres.shapes.RECTANGLE, {
      x: opts.x, y: opts.y, w: opts.w, h: opts.h,
      fill: { color: C.light },
      line: { color: C.line, width: 1, dashType: "dash" }
    });
    slide.addText("图片：" + imgPath.split(/[\\/]/).pop(), {
      x: opts.x + 0.1, y: opts.y + opts.h / 2 - 0.2,
      w: opts.w - 0.2, h: 0.4,
      fontSize: 10, color: C.gray, align: "center"
    });
  }
}

// 页面标题（统一风格）
function addPageTitle(slide, title, subtitle) {
  // 左侧竖线装饰
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.4, y: 0.45, w: 0.05, h: 0.55,
    fill: { color: C.blue }, line: { color: C.blue }
  });
  slide.addText(title, {
    x: 0.55, y: 0.42, w: 9, h: 0.5,
    fontSize: 28, bold: true, color: C.dark, margin: 0
  });
  if (subtitle) {
    slide.addText(subtitle, {
      x: 0.55, y: 0.95, w: 9, h: 0.3,
      fontSize: 13, color: C.gray, margin: 0
    });
  }
  // 底部分割线
  slide.addShape(pres.shapes.LINE, {
    x: 0.4, y: 1.32, w: 9.2, h: 0,
    line: { color: C.line, width: 1 }
  });
}

// ============================================================
// Slide 1 — 封面
// ============================================================
{
  const s = addSlide(C.dark);

  // 左侧红色竖条
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 0.35, h: 5.625,
    fill: { color: C.blue }, line: { color: C.blue }
  });

  // 右侧信息
  s.addText("信息论与编码", {
    x: 0.6, y: 1.5, w: 9, h: 0.7,
    fontSize: 36, bold: true, color: C.white, margin: 0
  });

  s.addShape(pres.shapes.LINE, {
    x: 0.6, y: 2.35, w: 7, h: 0,
    line: { color: "555555", width: 1 }
  });

  s.addText("期末实验答辩", {
    x: 0.6, y: 2.55, w: 9, h: 0.5,
    fontSize: 18, color: "AAAAAA", margin: 0
  });

  s.addText("香农 / 费诺 / 哈夫曼编码  ·  BSC/BEC 信道  ·  ML/MAP 译码", {
    x: 0.6, y: 3.2, w: 9, h: 0.4,
    fontSize: 12, color: "888888", margin: 0
  });

  // 底部信息
  s.addText("姓名：__________    学号：__________", {
    x: 0.6, y: 4.7, w: 9, h: 0.35,
    fontSize: 13, color: "888888", margin: 0
  });
}

// ============================================================
// Slide 2 — 实验目的
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验目的");

  const items = [
    { icon: "①", text: "实现三种信源编码（香农、费诺、哈夫曼）并对比性能" },
    { icon: "②", text: "通过 BSC（二元对称）和 BEC（二元删除）信道传输编码后的比特流" },
    { icon: "③", text: "使用 ML（极大似然）和 MAP（最大后验概率）译码恢复原始文本" },
    { icon: "④", text: "分析编码效率、压缩比、传输效率及字符错误率（CER）" },
    { icon: "⑤", text: "验证香农第一定理：信源熵是无损压缩的理论极限" },
  ];

  items.forEach((item, i) => {
    const y = 1.55 + i * 0.65;
    s.addText(item.icon, {
      x: 0.5, y, w: 0.4, h: 0.4,
      fontSize: 14, bold: true, color: C.blue,
      align: "center", margin: 0, valign: "middle"
    });
    s.addText(item.text, {
      x: 1.0, y, w: 8.3, h: 0.4,
      fontSize: 13, color: C.text, margin: 0, valign: "middle"
    });
    if (i < items.length - 1) {
      s.addShape(pres.shapes.LINE, {
        x: 1.0, y: y + 0.5, w: 8.3, h: 0,
        line: { color: C.line, width: 0.5 }
      });
    }
  });
}

// ============================================================
// Slide 3 — 系统框图
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验方案", "数字通信系统端到端仿真流程");

  const steps = [
    { label: "信源文本",  sub: "任意文本输入",       color: C.accent },
    { label: "信源统计",  sub: "概率分布 / 信源熵",  color: "0F3460" },
    { label: "信源编码",  sub: "Shannon / Fano / Huffman", color: "533483" },
    { label: "信道传输",  sub: "BSC 或 BEC 信道",  color: C.blue },
    { label: "信道译码",  sub: "ML 或 MAP",        color: "E94560" },
    { label: "性能评估",  sub: "CER / 编码效率",    color: "0A8F08" },
  ];

  const boxW = 1.45, boxH = 1.0, gap = 0.12;
  const startX = 0.35;

  steps.forEach((st, i) => {
    const x = startX + i * (boxW + gap);
    if (i > 0) {
      s.addShape(pres.shapes.LINE, {
        x: startX + (i - 1) * (boxW + gap) + boxW + 0.01,
        y: 2.6, w: gap - 0.02, h: 0,
        line: { color: C.gray, width: 1.5, endArrowType: "triangle" }
      });
    }
    s.addShape(pres.shapes.RECTANGLE, {
      x, y: 2.1, w: boxW, h: boxH,
      fill: { color: st.color }, line: { color: st.color }
    });
    s.addText(st.label, {
      x, y: 2.2, w: boxW, h: 0.45,
      fontSize: 12, bold: true, color: C.white,
      align: "center", margin: 0, valign: "middle"
    });
    s.addText(st.sub, {
      x, y: 2.7, w: boxW, h: 0.3,
      fontSize: 9, color: "CCCCCC",
      align: "center", margin: 0, valign: "middle"
    });
  });

  s.addText("图 1  数字通信系统仿真流程", {
    x: 0.35, y: 3.2, w: 9.3, h: 0.3,
    fontSize: 11, color: C.gray, align: "center", italic: true, margin: 0
  });

  // 说明
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.35, y: 3.65, w: 9.3, h: 1.5,
    fill: { color: "F9F9F9" }, line: { color: C.line, width: 0.5 }
  });
  s.addText([
    { text: "实验信源：", options: { bold: true, color: C.dark } },
    { text: "「关山难越，谁悲失路之人 The theory of information & coding 4396」", options: { color: C.text } }
  ], {
    x: 0.55, y: 3.8, w: 9, h: 0.4, fontSize: 11, margin: 0
  });
  s.addText("→ 含中文字符、英文字母、数字与标点，符号分布不均匀，适合检验编码性能差异。", {
    x: 0.55, y: 4.3, w: 9, h: 0.6,
    fontSize: 11, color: C.gray, margin: 0, valign: "top"
  });
}

// ============================================================
// Slide 4 — 信源编码原理（三栏卡片）
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "信源编码原理", "香农 / 费诺 / 哈夫曼");

  const methods = [
    {
      title: "哈夫曼编码",
      badge: "最优",
      color: "0A8F08",
      principle: "最优前缀码：每次合并概率最小的两个节点，自底向上构造二叉树",
      features: ["平均码长最短（Huffman 1952 证明）", "实际应用最广泛"]
    },
    {
      title: "香农编码",
      badge: "理论",
      color: C.accent,
      principle: "码长 li = ⌈−log₂ pi⌉，累积概率 Fi 的二进制展开取前 li 位",
      features: ["H ≤ L̄ < H+1（理论保证）", "适合理论分析与教学"]
    },
    {
      title: "费诺编码",
      badge: "",
      color: "533483",
      principle: "递归二分：每次将符号集分成概率和最接近的两组，左赋 0 右赋 1",
      features: ["效率介于香农与哈夫曼之间", "不保证最优"]
    }
  ];

  const cx = [0.35, 3.55, 6.75];
  methods.forEach((m, i) => {
    // 卡片阴影
    s.addShape(pres.shapes.RECTANGLE, {
      x: cx[i] + 0.03, y: 1.48, w: 3.0, h: 3.6,
      fill: { color: "000000", transparency: 95 },
      line: { color: "000000", transparency: 100 }
    });
    s.addShape(pres.shapes.RECTANGLE, {
      x: cx[i], y: 1.45, w: 3.0, h: 3.6,
      fill: { color: C.white },
      line: { color: m.badge ? m.color : C.line, width: m.badge ? 2 : 1 }
    });

    // 顶部色条
    s.addShape(pres.shapes.RECTANGLE, {
      x: cx[i], y: 1.45, w: 3.0, h: 0.35,
      fill: { color: m.color }, line: { color: m.color }
    });
    s.addText(m.title, {
      x: cx[i], y: 1.45, w: m.badge ? 2.5 : 3.0, h: 0.35,
      fontSize: 13, bold: true, color: C.white,
      align: "center", margin: 0, valign: "middle"
    });
    if (m.badge) {
      s.addShape(pres.shapes.OVAL, {
        x: cx[i] + 2.6, y: 1.5, w: 0.25, h: 0.25,
        fill: { color: C.blue }, line: { color: C.white, width: 1 }
      });
      s.addText(m.badge, {
        x: cx[i] + 2.6, y: 1.5, w: 0.25, h: 0.25,
        fontSize: 8, bold: true, color: C.white,
        align: "center", margin: 0, valign: "middle"
      });
    }

    // 原理
    s.addText("原理", {
      x: cx[i] + 0.12, y: 1.88, w: 2.8, h: 0.25,
      fontSize: 10, bold: true, color: m.color, margin: 0
    });
    s.addText(m.principle, {
      x: cx[i] + 0.12, y: 2.18, w: 2.8, h: 1.05,
      fontSize: 10, color: C.text, margin: 0, valign: "top"
    });

    // 特点
    s.addText("特点", {
      x: cx[i] + 0.12, y: 3.3, w: 2.8, h: 0.25,
      fontSize: 10, bold: true, color: m.color, margin: 0
    });
    m.features.forEach((f, j) => {
      s.addText("· " + f, {
        x: cx[i] + 0.12, y: 3.6 + j * 0.3, w: 2.8, h: 0.28,
        fontSize: 10, color: C.text, margin: 0, valign: "top"
      });
    });
  });
}

// ============================================================
// Slide 5 — 信道模型（BSC + BEC）
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "信道模型", "BSC（二元对称）与 BEC（二元删除）");

  // BSC
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.35, y: 1.45, w: 4.4, h: 3.7,
    fill: { color: "FFF5F5" },
    line: { color: C.blue, width: 1.5 }
  });
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.35, y: 1.45, w: 4.4, h: 0.38,
    fill: { color: C.blue }, line: { color: C.blue }
  });
  s.addText("BSC — 二元对称信道", {
    x: 0.35, y: 1.45, w: 4.4, h: 0.38,
    fontSize: 13, bold: true, color: C.white,
    align: "center", margin: 0, valign: "middle"
  });
  s.addText([
    { text: "模型定义", options: { bold: true, color: C.blue, breakLine: true } },
    { text: "  P(y|x) = 1−p  (y=x)", options: {} },
    { text: "\n  P(y|x) = p  (y≠x)", options: {} },
    { text: "\n\n特点", options: { bold: true, color: C.blue, breakLine: true } },
    { text: "  错误位置未知，译码难度大", options: {} }
  ], {
    x: 0.55, y: 2.0, w: 4.0, h: 2.8,
    fontSize: 11, color: C.text, margin: 0, valign: "top"
  });

  // BEC
  s.addShape(pres.shapes.RECTANGLE, {
    x: 5.25, y: 1.45, w: 4.4, h: 3.7,
    fill: { color: "F0F9FF" },
    line: { color: C.accent, width: 1.5 }
  });
  s.addShape(pres.shapes.RECTANGLE, {
    x: 5.25, y: 1.45, w: 4.4, h: 0.38,
    fill: { color: C.accent }, line: { color: C.accent }
  });
  s.addText("BEC — 二元删除信道", {
    x: 5.25, y: 1.45, w: 4.4, h: 0.38,
    fontSize: 13, bold: true, color: C.white,
    align: "center", margin: 0, valign: "middle"
  });
  s.addText([
    { text: "模型定义", options: { bold: true, color: C.accent, breakLine: true } },
    { text: "  以概率 1−ε 正确接收", options: {} },
    { text: "\n  以概率 ε 被删除（接收端知晓删除位置）", options: {} },
    { text: "\n\n特点", options: { bold: true, color: C.accent, breakLine: true } },
    { text: "  删除位置已知，可利用此信息进行译码", options: {} }
  ], {
    x: 5.45, y: 2.0, w: 4.0, h: 2.8,
    fontSize: 11, color: C.text, margin: 0, valign: "top"
  });
}

// ============================================================
// Slide 6 — ML vs MAP 译码原理
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "译码原理", "ML（极大似然）与 MAP（最大后验概率）");

  const cards = [
    {
      title: "极大似然（ML）译码",
      color: C.blue,
      formula: "ĉ = argmax  P(r | ci)",
      explain: "选择使接收序列 r 出现概率最大的码字",
      note: "BSC 下等价于：最小化汉明距离 dH(r, ci)"
    },
    {
      title: "最大后验概率（MAP）译码",
      color: "0A8F08",
      formula: "ĉ = argmax  P(ci | r) ∝ P(r | ci)·P(ci)",
      explain: "在似然概率基础上引入先验概率 P(ci)",
      note: "先验分布不均匀时，MAP 性能优于 ML"
    }
  ];

  const cx = [0.35, 5.25];
  cards.forEach((c, i) => {
    s.addShape(pres.shapes.RECTANGLE, {
      x: cx[i], y: 1.45, w: 4.5, h: 3.7,
      fill: { color: "F9F9F9" },
      line: { color: c.color, width: 1.5 }
    });
    s.addText(c.title, {
      x: cx[i] + 0.15, y: 1.6, w: 4.2, h: 0.38,
      fontSize: 13, bold: true, color: c.color, margin: 0
    });
    // 公式框
    s.addShape(pres.shapes.RECTANGLE, {
      x: cx[i] + 0.15, y: 2.1, w: 4.2, h: 0.45,
      fill: { color: c.color, transparency: 10 },
      line: { color: c.color }
    });
    s.addText(c.formula, {
      x: cx[i] + 0.15, y: 2.1, w: 4.2, h: 0.45,
      fontSize: 11, color: C.white, bold: true,
      align: "center", margin: 0, valign: "middle"
    });
    s.addText(c.explain, {
      x: cx[i] + 0.15, y: 2.7, w: 4.2, h: 0.5,
      fontSize: 11, color: C.text, margin: 0, valign: "top"
    });
    s.addText(c.note, {
      x: cx[i] + 0.15, y: 3.3, w: 4.2, h: 0.5,
      fontSize: 10, color: c.color, margin: 0, valign: "top"
    });
  });

  s.addText("结论：当信源符号先验分布不均匀时，MAP 译码性能优于 ML 译码", {
    x: 0.35, y: 5.2, w: 9.3, h: 0.32,
    fontSize: 12, bold: true, color: C.dark,
    align: "center", margin: 0
  });
}

// ============================================================
// Slide 7 — 性能指标（无公式列）
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "性能指标", "编码效率 / 压缩比 / 传输效率 / CER");

  const metrics = [
    { icon: "η", label: "编码效率", def: "η = H（信源熵）/ L̄（平均码长）", note: "理论极限 100%，越接近越好" },
    { icon: "CR", label: "压缩比",   def: "CR = 8（原始）/ L̄（平均码长）", note: "值越高说明压缩效果越好" },
    { icon: "TE", label: "传输效率", def: "TE = H / L̄", note: "综合反映编码方案的实际传输表现" },
    { icon: "CER", label: "字符错误率", def: "CER = 错误字符数 / 总字符数", note: "衡量译码准确性的核心指标，越低越好" },
  ];

  // 2x2 网格
  const positions = [[0.35, 1.45], [5.05, 1.45], [0.35, 3.35], [5.05, 3.35]];
  metrics.forEach((m, i) => {
    const [x, y] = positions[i];
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 4.6, h: 1.75,
      fill: { color: C.white },
      line: { color: C.line, width: 1 }
    });
    // 左侧色条
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 0.06, h: 1.75,
      fill: { color: C.accent }, line: { color: C.accent }
    });
    s.addText(m.icon, {
      x: x + 0.15, y: y + 0.1, w: 0.5, h: 0.5,
      fontSize: 18, bold: true, color: C.accent,
      align: "center", margin: 0, valign: "middle"
    });
    s.addText(m.label, {
      x: x + 0.7, y: y + 0.1, w: 3.7, h: 0.5,
      fontSize: 14, bold: true, color: C.dark, margin: 0, valign: "middle"
    });
    s.addShape(pres.shapes.LINE, {
      x: x + 0.15, y: y + 0.68, w: 4.3, h: 0,
      line: { color: C.line, width: 0.5 }
    });
    s.addText(m.def, {
      x: x + 0.15, y: y + 0.78, w: 4.3, h: 0.42,
      fontSize: 11, color: C.text, margin: 0, valign: "middle"
    });
    s.addText(m.note, {
      x: x + 0.15, y: y + 1.25, w: 4.3, h: 0.4,
      fontSize: 10, color: C.gray, margin: 0, valign: "top"
    });
  });
}

// ============================================================
// Slide 8 — 实验结果：文本传输对比
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结果", "文本传输对比（原文 vs 译码文本）");

  addImageSafe(s, "C:/Users/li/Documents/MATLAB/digital_comm_system/output/text_comparison_huffman_map.png", {
    x: 0.4, y: 1.4, w: 9.2, h: 3.8,
    sizing: { type: "contain" }
  });

  s.addText([
    { text: "说明：", options: { bold: true, color: C.dark } },
    { text: " 左栏为原始信源文本，右栏为译码后文本；相似度越高，该编码+译码组合性能越好。" }
  ], {
    x: 0.4, y: 5.25, w: 9.2, h: 0.3,
    fontSize: 11, color: C.gray, margin: 0
  });
}

// ============================================================
// Slide 9 — 实验结果：三种编码对比
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结果", "三种编码方式对比（并列）");

  addImageSafe(s, "C:/Users/li/Documents/MATLAB/digital_comm_system/output/encoding_parallel_results_bsc.png", {
    x: 0.4, y: 1.4, w: 9.2, h: 3.8,
    sizing: { type: "contain" }
  });

  s.addText("图 2  三种编码方案的平均码长、编码效率、压缩比和传输效率对比", {
    x: 0.4, y: 5.25, w: 9.2, h: 0.3,
    fontSize: 11, color: C.gray, align: "center", italic: true, margin: 0
  });
}

// ============================================================
// Slide 10 — 实验结果：四指标分析
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结果", "编码性能四指标分析");

  addImageSafe(s, "C:/Users/li/Documents/MATLAB/digital_comm_system/output/encoding_performance_4metrics.png", {
    x: 0.4, y: 1.4, w: 9.2, h: 3.8,
    sizing: { type: "contain" }
  });
}

// ============================================================
// Slide 11 — 实验结果：BER-CER 曲线
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结果", "BSC 信道下 CER 随误码率变化（ML vs MAP）");

  addImageSafe(s, "C:/Users/li/Documents/MATLAB/digital_comm_system/output/ber_cer_curve.png", {
    x: 0.4, y: 1.4, w: 9.2, h: 3.8,
    sizing: { type: "contain" }
  });

  s.addText([
    { text: "关键观察：", options: { bold: true, color: C.dark, breakLine: true } },
    { text: "• MAP 译码（红色虚线）始终优于 ML 译码（蓝色实线）", options: { breakLine: true } },
    { text: "• Huffman 编码的 CER 增长最慢，抗噪声能力最强", options: { breakLine: true } },
    { text: "• 当 p → 0.5 时，所有方案性能趋于随机（CER → 1）", options: {} }
  ], {
    x: 0.4, y: 5.25, w: 9.2, h: 0.35,
    fontSize: 11, color: C.text, margin: 0
  });
}

// ============================================================
// Slide 12 — 实验结果：CER 随信道参数变化
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结果", "CER 随信道参数变化（三种编码对比）");

  addImageSafe(s, "C:/Users/li/Documents/MATLAB/digital_comm_system/output/cer_vs_channel_prob_three_encodings_bsc_map.png", {
    x: 0.4, y: 1.4, w: 9.2, h: 3.8,
    sizing: { type: "contain" }
  });
}

// ============================================================
// Slide 13 — 实验结论
// ============================================================
{
  const s = addSlide(C.white);
  addPageTitle(s, "实验结论");

  const conclusions = [
    "Huffman 编码平均码长最短、编码效率最高，是三种方案中的最优选择",
    "MAP 译码引入先验概率，在先验分布不均匀时性能优于 ML 译码",
    "BEC 信道删除位置已知，相同参数下性能优于 BSC 信道",
    "压缩效率越高的编码方案对信道错误越敏感，需权衡压缩率与鲁棒性",
  ];

  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.35, y: 1.45, w: 9.3, h: 2.2,
    fill: { color: "F9F9F9" },
    line: { color: C.line, width: 1 }
  });

  conclusions.forEach((c, i) => {
    s.addText("▸  " + c, {
      x: 0.55, y: 1.6 + i * 0.5, w: 9.0, h: 0.42,
      fontSize: 12, color: C.text, margin: 0, valign: "middle"
    });
  });

  // 展望
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.35, y: 3.85, w: 9.3, h: 1.45,
    fill: { color: "FFF9F0" },
    line: { color: "F59E0B", width: 1.5 }
  });
  s.addText("可扩展方向", {
    x: 0.55, y: 3.98, w: 9.0, h: 0.32,
    fontSize: 13, bold: true, color: "92400E", margin: 0
  });
  s.addText([
    { text: "➤  ", options: { bold: true, color: "92400E" } },
    { text: "加入信道编码（Hamming、CRC）构成更完整的通信系统", options: { breakLine: true } },
    { text: "➤  ", options: { bold: true, color: "92400E" } },
    { text: "扩展至 AWGN 信道，更贴近真实通信场景", options: { breakLine: true } },
    { text: "➤  ", options: { bold: true, color: "92400E" } },
    { text: "对比理论信道容量曲线，验证仿真结果的理论一致性", options: {} }
  ], {
    x: 0.55, y: 4.38, w: 9.0, h: 0.8,
    fontSize: 11, color: "92400E", margin: 0, valign: "top"
  });
}

// ============================================================
// Slide 14 — 致谢
// ============================================================
{
  const s = addSlide(C.dark);

  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 0.35, h: 5.625,
    fill: { color: C.blue }, line: { color: C.blue }
  });

  s.addText("谢谢！", {
    x: 0.6, y: 1.8, w: 9, h: 1.0,
    fontSize: 52, bold: true, color: C.white,
    align: "center", margin: 0
  });

  s.addShape(pres.shapes.LINE, {
    x: 2.5, y: 2.95, w: 5.0, h: 0,
    line: { color: C.blue, width: 2 }
  });

  s.addText("请老师批评指正", {
    x: 0.6, y: 3.15, w: 9, h: 0.5,
    fontSize: 20, color: "AAAAAA",
    align: "center", margin: 0
  });
}

// ===== 输出 =====
const outPath = "C:/Users/li/Documents/MATLAB/digital_comm_system/信息论与编码实验答辩_v2.pptx";
pres.writeFile({ fileName: outPath })
  .then(() => {
    console.log("✅  PPT 已生成：" + outPath);
  })
  .catch(err => {
    console.error("❌  生成失败：" + err.message);
    process.exit(1);
  });
