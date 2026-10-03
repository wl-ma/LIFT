# LIFT

**面向可复用数学知识的形式化定理库整合**

[English](README.md) · [论文实验](docs/experiments.md) · [复现指南](docs/reproducibility.md) · [数学案例](examples/paper-cases/README.md) · [许可证](LICENSES.md)

LIFT 将形式化数学项目整合为可复用的 Lean 接口，同时构造从公共接口恢复原始规格的证明或映射。这些公共数学组件组成 **ReasLib**。

![LIFT 方法概览](docs/assets/method-overview.png)

## 方法

LIFT 联合处理公共接口与来源恢复：复用已有定理、将具体论证推广到更一般的接口，或通过表示映射连接不同构造；随后验证原始完整类型，以及构造所要求的定义方程和运算规律。

多个生产者可以并发构建候选，单个消费者将候选整合到持续更新的库中。需要修改的候选返回修订，并可使用此前已接受的新接口。[方法说明](docs/method.md)。

## 论文实验

| 实验目的 | 结果与证据 | 入口 |
| --- | --- | --- |
| 数学库构建 | 20 个项目，10,922 个目录条目，5,061 次接受的来源条目整合 | [构建数据](experiments/corpus-construction/README.md) |
| 来源恢复 | 7 组证明交接；249 个义务关联成功任务；5 个案例文件、9 个声明有编译与公理检查 | [恢复链](experiments/source-recovery/README.md) |
| 后续复用 | 法锥公共接口恢复半径 1/2 的来源结果，并用于半径 12 的研究证明 | [实际调用](experiments/downstream-reuse/README.md) |
| 在线修订 | 同余接口进入 Beck 修订证明；检查点覆盖 20 个来源声明与 22 个客户端 | [事件与快照](experiments/online-revision/README.md) |

![构建过程中的声明决策](docs/assets/result-action-profile.svg)

15,716 个公共模块出现记录包含继承内容和未完成证明。声明决策按动作计数：复用 8,854、发布 19,253、本地保留 2,568、移除 3,283。任务关联属于历史执行证据；选定 Lean 案例另有编译与公理证据。[统计口径及论文对应表](docs/experiments.md)。

## 快速使用

从[论文材料链接](https://anonymous.4open.science/r/LIFT-C5F7/)下载并解压，在根目录运行（Python 3.10 及以上）：

```bash
python3 scripts/verify_release.py
python3 scripts/verify_artifacts.py
python3 scripts/reproduce_tables.py --check
```

生成表格和图：

```bash
python3 scripts/reproduce_tables.py --output _runs/tables
python3 -m pip install -r requirements-plots.txt
python3 scripts/plot_results.py --output _runs/figures
```

直接打开 [demo/index.html](demo/index.html)，可离线查看项目目录、数学案例和在线修订时间线。

## 数学案例与工具

[数学案例](examples/paper-cases/README.md)包括一阶最优性、Taylor 公式、乘积基本群、法锥接口及 Beck 在线修订。各项目固定 Lean 与 Mathlib 依赖，并提供来源应用与审计入口。安装 [Elan](https://github.com/leanprover/elan) 和 Git 后，可编译微积分与拓扑案例：

```bash
cd examples/paper-cases/reaslib
lake update
lake exe cache get
lake build
lake env lean Audit.lean
```

[Lean → JSON](tools/lean_json/README.md)从编译环境提取完整类型、定义体、依赖和公理信息；[工具链对齐](tools/toolchain/README.md)在独立副本中准备固定目标版本，比较声明并检查原客户端。[完整复现流程](docs/reproducibility.md)。

## ReasLib 串行构建示例

[交互结果页](demo/serial.html) · [Lean 项目](examples/reaslib-serial/README.md) · [构建记录](experiments/serial-library-growth/README.md)

同一项目依次加入 Beck、Bauschke–Combettes 和 Nesterov 三本教材的内容，每一步完成陈述、库整合及证明流程。六个批次形成的最终库有 **180 个可信声明**，保留 **18 个来源接口**和 **51 项表示义务**，通过 **69 项固定来源检查**、**25 个扩展边界案例**及原有 **21 项独立检查**。共享接口连接强凸性、约束二次函数、可微曲率、次梯度强单调性与预解算子收缩界。

```bash
python3 scripts/check_serial_demo.py --output _runs/reaslib-serial
```

依赖安装见项目指南。交互页展示三个接受版本、完整声明类型与依赖、全部执行尝试和已结算用量。该可执行示例对应论文的 ReasLib 方法，结果与论文实验表格分别记录。

## 目录结构

- `src/lift_artifacts/`：共享分析与校验实现；`scripts/`：命令入口。
- `experiments/`：按实验目的组织输入、结果和数据字典。
- `examples/paper-cases/`：论文案例；`examples/reaslib-serial/`：三来源串行构建的数学库与独立客户端。
- `tools/`：声明提取与工具链对齐工具。
- `docs/`：方法、论文对应、复现说明和插图。
- `metadata/`：文件注册表、来源及完整性摘要。
- `demo/`：离线证据浏览页面。

新的本地检查写入 `_runs/`，已发布的实验记录单独保留。[验证范围](docs/validation.md)。

## 引用与许可

引用名称：**LIFT: Library Integration of Formalized Theorems for Reusable Mathematical Knowledge**；材料链接为[论文仓库](https://anonymous.4open.science/r/LIFT-C5F7/)。

原创软件采用 **Apache-2.0**；原创文档、插图及整理后的统计数据采用 **CC BY 4.0**。第三方材料与具体路径例外见 [LICENSES.md](LICENSES.md)。

## 独立工具与后续构库

编译提取、自然语言翻译及语义审核、带自动修复的工具链迁移集中在 `src/lift_tools/`；实验复核在 `src/lift_artifacts/`。两者均可独立于构库后端使用。完整构库仍通过外部后端执行，其实现不随本仓库发布。[依赖与安装](docs/dependencies.md)。

[扩展来源与流程](experiments/serial-library-growth/extension-plan.md)记录三本教材的六项新增条目及一项单列表示桥接；[补充证明案例](experiments/serial-library-growth/supplementary/README.md)分别展示原目标证明和实际接口调用。
