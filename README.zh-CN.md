# LIFT

**Library Integration of Formalized Theorems for Reusable Mathematical Knowledge**

[English](README.md) · [数据说明](data/README.md) · [ReasLib 示例](examples/reaslib/README.md) · [复现指南](docs/reproduce.md)

LIFT 研究怎样把独立形式化的 Lean 项目组织为可复用的数学库。核心是同时确定公共接口和回到原始数学要求的适配关系：公共结论应能恢复来源命题；公共构造还要保留所要求的数据、定义方程与运算规律。多个候选可以并行构造，接纳和修订时使用当前库中的内容。

本仓库存放论文相关的公开实验材料、ReasLib 示例和配套工具。首批内容对应 **2026-09-26 16:27 固定的 version6 论文**，稿件哈希与文件来源见[发布溯源](data/release-provenance.json)。

## 先看什么

- 想了解论文：阅读[完整英文 README](README.md)及[方法说明](docs/method.md)。
- 想浏览数据与案例：下载或克隆仓库，在浏览器打开 [demo/index.html](demo/index.html)。页面包含搜索、领域筛选、三个数学案例及在线更新轨迹，不需要服务器或模型。
- 想检查统计：[data/](data/README.md) 提供 CSV、JSON 与字段定义。
- 想运行 Lean：[examples/reaslib/](examples/reaslib/README.md) 包含实际公共模块和来源应用。
- 想用转换或迁移工具：[Lean→JSON](tools/lean_json/README.md) 与[工具链辅助工具](tools/toolchain/README.md) 提供独立命令。

## 当前发布的数据

| 内容 | 数量及含义 |
| --- | --- |
| 构建覆盖 | 20 个数学项目；10,922 个目录条目；5,061 个成功整合条目 |
| 公共库规模 | 15,716 次项目内公共模块出现，含继承内容及未完成证明的接口 |
| 声明决策 | 8,854 次复用；19,253 次发布；2,568 次局部保留；3,283 次移除 |
| 证明交接 | 7 个批次；118 个整合工作项；135 个成功证明任务；249 条义务关联 |
| 数学案例 | 5 个编译文件；9 个声明的公理依赖检查 |
| Beck 在线案例 | 成功修订后的检查点：20 个原声明、15 个可信来源定理、22 个固定客户端 |

这些数字的统计单位不同。整合条目、模块出现和任务成功都不等于新增可信定理数。249 条关联反映记录中的证明交接；所选 9 个声明才有对应的独立公理检查。完整定义见[数据说明](data/README.md)。

## ReasLib demo 展示什么

当前 ReasLib 指历史项目中的公共数学组件。本次公开的 Lean 示例包抽取其中两份公共模块与三份来源应用，保留原始文件及哈希：

1. **一阶最优性**：把来源的 EuclideanSpace 类型对齐到已有导数定理。
2. **Taylor 公式**：在一般实赋范空间给出公共接口，再特化到有限维来源。
3. **积空间基本群**：构造投影与配对同态，证明互逆律，并组成可调用的乘法等价。

浏览 demo 用于理解与定位；Lean 示例用于实际编译。它们不宣称把全部 20 个项目合并成了已经完成验证的统一库。

Beck 轨迹展示一个新接纳的强凸性相等替换接口，如何进入后续候选修订后的来源证明。发布的事件表、实际补丁和检查点可以对应阅读。这是来源内部的具体复用案例；原整轮运行后来未通过最终公共清单检查，第二轮没有接纳数学更新，不能从本案例推导普遍性能优势。

## 快速检查

```bash
git clone https://github.com/wl-ma/LIFT.git
cd LIFT
python3 scripts/verify_release.py
```

Python 3.10+ 即可运行数据校验，不需要额外 Python 依赖。

编译数学示例需要 Elan、Git，以及首次下载的 Lean/Mathlib 依赖：

```bash
cd examples/reaslib
lake update
lake exe cache get
lake build
lake env lean Audit.lean
```

示例固定 Lean 4.32.0 和 Mathlib 提交 `81a5d257c8e410db227a6665ed08f64fea08e997`。版本不能仅按“越新越好”替换：形式化代码同时依赖编译器和 Mathlib 接口，二者需要匹配。核查结果与缓存使用方式见[复现指南](docs/reproduce.md)。

## 工具能做到哪一步

**Lean→JSON** 从编译后的环境提取完整类型、定义体、所属模块、位置、依赖、公理等事实，用 `Module::name` 区分声明身份。它不把源码字符串猜测当作编译器事实，也不自动把提取结果标记为完成自然语言审查。仓库附有既有翻译和核查提示词；自然语言模型执行后端尚未作为此公开命令的一部分发布。

**工具链辅助工具** 创建新副本，固定目标 Lean/Mathlib，运行构建并比较升级前后的声明事实。当前支持 `lakefile.toml`，可检测名称缺失、类型或定义体变化、公理变化。构建成功与接口保持是两种不同检查；程序不会自动修复任意 API 变化，也不能以字符串相同证明跨版本语义等价。

本次发布未启动模型调用或新的论文实验。原教材全文、全部历史源码包、内部服务配置和原始会话日志未纳入仓库。来源、复用边界及后续仍待补充的内容见[来源说明](docs/provenance-and-reuse.md)和[验证记录](docs/validation.md)。
