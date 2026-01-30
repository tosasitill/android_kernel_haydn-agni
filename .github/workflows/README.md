# AGNi Kernel GitHub Actions 构建指南 / Build Guide

[English](#english) | [中文](#中文)

---

## 中文

### 简介

此 GitHub Actions 工作流用于自动编译 AGNi_haydn_MIUI_ST 分支的 Android 内核。工作流支持以下编译版本：

- **标准版本（HyperOS）**：带 KernelSU 和不带 KernelSU 两个版本
- **90Hz 版本（HyperOS-90HZ）**：带 KernelSU 和不带 KernelSU 两个版本

### 触发方式

工作流将在以下情况下自动触发：

1. **推送到 AGNi_haydn_MIUI_ST 分支**：当您推送代码到此分支时自动编译
2. **创建 Pull Request**：当创建针对 AGNi_haydn_MIUI_ST 分支的 PR 时
3. **手动触发**：在 GitHub Actions 页面手动运行工作流

### 手动触发步骤

1. 访问您的仓库的 Actions 页面
2. 在左侧选择 "Build AGNi Kernel" 工作流
3. 点击右侧的 "Run workflow" 按钮
4. 选择 AGNi_haydn_MIUI_ST 分支
5. 点击绿色的 "Run workflow" 按钮

### 下载编译产物

编译完成后，您可以在 Actions 运行记录的底部找到以下产物：

- `AGNi-Kernel-HyperOS-KSU` - 标准版本带 KernelSU
- `AGNi-Kernel-HyperOS-NoKSU` - 标准版本不带 KernelSU
- `AGNi-Kernel-HyperOS-90HZ-KSU` - 90Hz 版本带 KernelSU
- `AGNi-Kernel-HyperOS-90HZ-NoKSU` - 90Hz 版本不带 KernelSU

### 工作流说明

工作流使用以下配置：

- **运行环境**：Ubuntu Latest
- **编译器**：Google Clang (clang-r450784d)
- **架构**：ARM64
- **配置文件**：agni_haydn_defconfig
- **输出格式**：AnyKernel3 ZIP 包

### 编译时间

根据 GitHub Actions 的性能，完整编译通常需要：
- 单个版本：约 30-60 分钟
- 两个版本并行：约 40-70 分钟

### 故障排除

如果编译失败，请检查：

1. 确认分支名称正确（AGNi_haydn_MIUI_ST）
2. 检查 Actions 日志中的错误信息
3. 确认所有子模块已正确初始化
4. 验证工具链下载是否成功

---

## English

### Introduction

This GitHub Actions workflow automatically compiles the Android kernel for the AGNi_haydn_MIUI_ST branch. The workflow supports the following build variants:

- **Standard Version (HyperOS)**: With KernelSU and Without KernelSU
- **90Hz Version (HyperOS-90HZ)**: With KernelSU and Without KernelSU

### Trigger Methods

The workflow will automatically trigger under the following conditions:

1. **Push to AGNi_haydn_MIUI_ST branch**: Automatically compiles when you push code to this branch
2. **Pull Request**: When creating a PR targeting the AGNi_haydn_MIUI_ST branch
3. **Manual Trigger**: Manually run the workflow from the GitHub Actions page

### Manual Trigger Steps

1. Navigate to your repository's Actions page
2. Select "Build AGNi Kernel" workflow from the left sidebar
3. Click the "Run workflow" button on the right
4. Select the AGNi_haydn_MIUI_ST branch
5. Click the green "Run workflow" button

### Download Build Artifacts

After compilation completes, you can find the following artifacts at the bottom of the Actions run page:

- `AGNi-Kernel-HyperOS-KSU` - Standard version with KernelSU
- `AGNi-Kernel-HyperOS-NoKSU` - Standard version without KernelSU
- `AGNi-Kernel-HyperOS-90HZ-KSU` - 90Hz version with KernelSU
- `AGNi-Kernel-HyperOS-90HZ-NoKSU` - 90Hz version without KernelSU

### Workflow Configuration

The workflow uses the following configuration:

- **Runtime Environment**: Ubuntu Latest
- **Compiler**: Google Clang (clang-r450784d)
- **Architecture**: ARM64
- **Config File**: agni_haydn_defconfig
- **Output Format**: AnyKernel3 ZIP package

### Build Time

Based on GitHub Actions performance, a full build typically takes:
- Single variant: Approximately 30-60 minutes
- Two variants in parallel: Approximately 40-70 minutes

### Troubleshooting

If the build fails, please check:

1. Verify the branch name is correct (AGNi_haydn_MIUI_ST)
2. Check error messages in the Actions logs
3. Ensure all submodules are properly initialized
4. Verify the toolchain download was successful

---

## 工作流文件位置 / Workflow File Location

`.github/workflows/build_kernel.yml`

## 许可证 / License

本工作流配置文件基于项目原有的构建脚本创建，遵循项目的许可证条款。

This workflow configuration is created based on the project's existing build scripts and follows the project's license terms.
