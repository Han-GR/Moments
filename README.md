# 每事每刻

<div align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/iOS-17.0+-green.svg" alt="iOS">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-purple.svg" alt="SwiftUI">
</div>

## 📱 项目概述

**每事每刻** 是一款专为记录生活中一切值得纪念事物而设计的iOS应用。基于"任何事物都值得被记录"的理念，这款应用帮助用户为生活中的每一个重要存在创建专属档案，记录它们的点点滴滴。

### ✨ 核心特色
- 🎯 **万物记录** - 为任何值得记录的事物创建独立档案
- 📸 **瞬间捕捉** - 支持图文并茂的生活记录
- 🏷️ **智能分组** - 灵活的分类管理系统
- 🎨 **精美界面** - 现代简约的设计风格
- 💾 **本地存储** - 数据安全，隐私保护

## 🎯 适用场景

- 🐱 **宠物记录** - 记录毛孩子的成长历程
- 🌱 **植物日志** - 追踪植物的生长变化
- 📚 **收藏管理** - 管理心爱的收藏品
- 🎨 **作品档案** - 记录创作过程和成果
- 🏠 **物品管理** - 追踪重要物品的状态
- 💝 **生活记录** - 保存生活中的美好瞬间

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| **SwiftUI** | 5.0+ | 用户界面框架 |
| **Swift Data** | iOS 17+ | 数据持久化 |
| **Combine** | - | 响应式编程 |
| **PhotosPicker** | iOS 16+ | 照片选择 |
| **Swift** | 5.9+ | 编程语言 |

### 🏗️ 架构设计
- **MVVM模式** - 清晰的数据绑定和状态管理
- **组件化开发** - 可复用的UI组件
- **响应式设计** - 适配不同屏幕尺寸
- **本地优先** - 安全的本地设备数据存储

## 📋 主要功能

### 🏠 首页管理
- 网格/列表视图切换
- 智能搜索和筛选
- 彩色分组管理
- 快速添加新档案

### 📝 详情展示
- 完整档案信息展示
- 生活瞬间时间线
- 照片轮播查看
- 一键编辑和管理

### 📸 瞬间记录
- 多图片上传支持
- 富文本内容编辑
- 自动时间记录
- 关联档案管理

### ⚙️ 系统设置
- 数据统计查看
- 一键数据清除
- 应用信息展示
- 隐私保护设置

## 页面结构

### 核心导航层
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 应用入口 | 应用生命周期管理 | 初始化Swift Data容器，设置全局环境 | SwiftUI App, Swift Data | 应用启动入口点 | `Moments/MomentsApp.swift` |
| 主标签视图 | 底部标签导航容器 | 管理主要功能模块的标签切换 | SwiftUI TabView | 主导航容器，包含所有主要页面 | `Moments/Views/MainTabView.swift` |

### 档案管理模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 首页 | 展示所有档案 | 网格/列表展示，搜索筛选，快速添加 | SwiftUI List/LazyVGrid, Swift Data | 标签栏首页，点击卡片进入详情 | `Moments/Views/HomeView.swift` |
| 详情页 | 档案详细信息展示 | 照片轮播，基本信息，生活记录预览 | SwiftUI ScrollView, Swift Data | 从首页进入，可跳转编辑和记事 | `Moments/Views/BabyDetailView.swift` |
| 编辑页 | 添加/编辑档案 | 照片选择，信息表单，数据验证 | SwiftUI Form, PhotosPicker | 从详情页或首页添加按钮进入 | `Moments/Views/BabyEditView.swift` |

### 生活记录模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 记事列表 | 展示所有生活记录 | 时间线展示，分类筛选，搜索功能 | SwiftUI List, Swift Data | 从标签栏或详情页进入 | `Moments/Views/MomentsView.swift` |
| 记事详情页 | 单条记录详细展示 | 图文详情，时间信息，关联档案 | SwiftUI ScrollView | 从记事列表点击进入 | `Moments/Views/MomentDetailView.swift` |
| 记事编辑页 | 添加/编辑生活记录 | 多图上传，富文本编辑，标签管理 | SwiftUI Form, PhotosPicker | 从记事详情或列表添加按钮进入 | `Moments/Views/MomentEditView.swift` |

### 系统功能模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 设置页 | 应用设置中心 | 数据统计，一键清除数据，关于页面 | SwiftUI Form, UserDefaults | 从标签栏或首页设置按钮进入 | `Moments/Views/SettingsView.swift` |

## 🗄️ 数据模型

### 📊 核心实体关系
```
Baby (记录对象)
├── id: UUID (唯一标识)
├── name: String (名称)
├── birthDate: Date (创建/获得日期)
├── photo: Data? (封面照片)
├── createdAt: Date (创建时间)
├── notes: String (备注信息)
├── group: Group? (所属分组)
└── moments: [Moment] (关联记录)

Moment (记录瞬间)
├── id: UUID (唯一标识)
├── content: String (内容描述)
├── date: Date (记录时间)
├── photos: [Data] (照片集合)
└── baby: Baby? (关联对象)

Group (分组管理)
├── id: UUID (唯一标识)
├── name: String (分组名称)
├── color: String (标识颜色)
├── createdAt: Date (创建时间)
└── babies: [Baby] (包含对象)
```

### 🔗 关系说明
- **一对多关系**: 一个记录对象可以有多个记录瞬间
- **多对一关系**: 多个记录对象可以属于同一个分组
- **可选关系**: 瞬间可以不关联特定对象（独立记录）

## 技术实现细节

### 架构设计
- **MVVM模式**: 使用SwiftUI的声明式编程和Combine框架实现数据绑定
- **导航结构**: 基于TabView的标签式导航，支持深度链接
- **数据流**: Swift Data + SwiftUI环境对象实现响应式数据更新

### 核心组件
- **MainTabView**: 主标签导航容器
- **数据持久化**: Swift Data容器管理，支持数据迁移
- **图片处理**: 支持多种格式图片的存储和显示优化

### 多语言与本地化
- 支持简体中文（zh-Hans）与英文（en）界面
- 当系统语言未单独适配时，默认使用英文界面显示
- 所有文案集中在 Localizable.strings 中，并按功能分组维护

## 🚀 快速开始

### 📋 系统要求
- **iOS**: 17.0 或更高版本
- **Xcode**: 15.0 或更高版本
- **Swift**: 5.9 或更高版本
- **设备**: iPhone/iPad (支持所有屏幕尺寸)

### 📱 使用指南

#### 🆕 创建第一个记录对象
1. 点击首页右上角的 `+` 按钮
2. 填写基本信息（名称、获得日期等）
3. 选择封面照片（可选）
4. 选择分组或创建新分组
5. 保存档案

#### 📝 记录重要瞬间
1. 在对象详情页点击"添加瞬间"
2. 选择关联的对象（可选）
3. 添加照片和文字描述
4. 设置记录时间
5. 保存瞬间

#### 🏷️ 管理分组
1. 在编辑对象时点击"管理分组"
2. 创建新分组并选择颜色
3. 为对象分配合适的分组
4. 在首页通过分组筛选查看

## 📊 开发状态（v1.0.0）

### ✅ 已完成功能
- [x] 🏗️ **核心架构** - SwiftUI + Swift Data 基础项目架构搭建
- [x] 📊 **数据模型** - 数据模型设计与实现
- [x] 🏠 **首页管理** - 档案展示、搜索、分组，主要页面UI实现
- [x] 📝 **档案管理** - 创建、编辑、删除档案，物品管理功能
- [x] 📸 **瞬间记录** - 图文记录、时间线展示，生活记录功能
- [x] 🏷️ **分组系统** - 颜色标识、灵活管理，分组管理功能
- [x] 🎨 **UI组件** - 头像组件、颜色主题，图片上传与显示
- [x] ⚙️ **系统设置** - 数据统计、清除功能
- [x] 🌍 **多语言支持** - 简体中文 / 英文界面与文案本地化
- [x] 📱 **响应式设计** - 适配各种屏幕尺寸
- [x] 🔧 **代码优化** - 应用大小优化，代码重构与组件化

## 项目结构

```
Moments/
├── Moments/
│   ├── MomentsApp.swift          # 应用入口
│   ├── Views/                   # 视图文件夹
│   │   ├── MainTabView.swift    # 主标签导航
│   │   ├── HomeView.swift       # 主页
│   │   ├── BabyDetailView.swift # 物品详情页
│   │   ├── BabyEditView.swift   # 物品编辑页
│   │   ├── MomentsView.swift    # 记事本列表
│   │   ├── MomentDetailView.swift # 记事详情页
│   │   ├── MomentEditView.swift # 记事编辑页
│   │   ├── SettingsView.swift   # 设置页
│   │   └── GroupManagementView.swift # 分组管理
│   ├── Components/              # 可重用组件
│   │   ├── BabyAvatarView.swift # 头像组件
│   │   └── ImagePicker.swift    # 图片选择器
│   ├── Models/                  # 数据模型
│   │   └── BabyModel.swift      # 数据模型
│   ├── Utils/                   # 工具类
│   │   └── AppColors.swift      # 颜色主题
│   ├── Extensions/              # 扩展文件夹
│   └── Assets.xcassets/         # 资源文件
├── MomentsTests/                 # 单元测试
├── MomentsUITests/               # UI测试
└── README.md                    # 项目说明
```
