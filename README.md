# AiBaBy (AiBaby)

## 项目概述
AiBaBy（AiBaby）是一款帮助用户管理自己的"阿贝贝"的iOS应用。在现代社会，很多人会有多个"阿贝贝"并将它们视为自己的孩子，这款应用旨在提供一个平台让用户可以记录和管理这些特别的存在。

## 目标用户
所有拥有"阿贝贝"并希望记录它们生活点滴的用户。用户可能将这些"阿贝贝"视为自己的孩子，希望有一个专门的平台来保存相关记忆。

## 技术选型
- 开发框架: SwiftUI
- 数据持久化: Swift Data
- 状态管理: Combine与SwiftUI原生状态管理
- UI风格: 遵循iOS Human Interface Guidelines (HIG)，采用暗色科技风现代简约设计

## 应用结构
应用采用标签式导航结构，主要包含以下几个主要部分：
- 主页：展示所有的"阿贝贝"
- 详情页：查看单个"阿贝贝"的详细信息
- 编辑页：添加或编辑"阿贝贝"的信息
- 记事本：记录关于"阿贝贝"的生活瞬间

## 页面结构

### 核心导航层
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 应用入口 | 应用生命周期管理 | 初始化Swift Data容器，设置全局环境 | SwiftUI App, Swift Data | 应用启动入口 | `AiBaBy/AiBaByApp.swift` |
| 主标签视图 | 底部标签导航容器 | 管理主要功能模块的标签切换 | SwiftUI TabView | 主导航容器，包含所有主要页面 | `AiBaBy/MainTabView.swift` |
| 内容视图 | 主要内容容器 | 承载主要业务逻辑视图 | SwiftUI | 连接标签导航和具体功能页面 | `AiBaBy/ContentView.swift` |

### 阿贝贝管理模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 主页 | 展示所有阿贝贝 | 网格/列表展示，搜索筛选，快速添加 | SwiftUI List/LazyVGrid, Swift Data | 标签栏首页，点击卡片进入详情 | `AiBaBy/HomeView.swift` |
| 详情页 | 阿贝贝详细信息展示 | 照片轮播，基本信息，生活记录预览 | SwiftUI ScrollView, Swift Data | 从主页进入，可跳转编辑和记事 | `AiBaBy/BabyDetailView.swift` |
| 编辑页 | 添加/编辑阿贝贝 | 照片选择，信息表单，数据验证 | SwiftUI Form, PhotosPicker | 从详情页或主页添加按钮进入 | `AiBaBy/BabyEditView.swift` |

### 生活记录模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 记事本列表 | 展示所有生活记录 | 时间线展示，分类筛选，搜索功能 | SwiftUI List, Swift Data | 标签栏或详情页进入 | `AiBaBy/MomentsView.swift` |
| 记事详情页 | 单条记录详细展示 | 图文详情，时间信息，关联阿贝贝 | SwiftUI ScrollView | 从记事本列表点击进入 | `AiBaBy/MomentDetailView.swift` |
| 记事编辑页 | 添加/编辑生活记录 | 多图上传，富文本编辑，标签管理 | SwiftUI Form, PhotosPicker | 从记事详情或列表添加按钮进入 | `AiBaBy/MomentEditView.swift` |

### 系统功能模块
| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 设置页 | 应用设置中心 | 主题切换，数据备份，通知设置，隐私管理 | SwiftUI Form, UserDefaults | 标签栏或主页设置按钮进入 | `AiBaBy/SettingsView.swift` |

## 数据模型

### Baby实体
- id: UUID
- name: String
- birthDate: Date
- photo: Data
- createdAt: Date
- notes: String
- moments: Relationship to Moment entities

### Moment实体
- id: UUID
- title: String
- content: String
- date: Date
- photos: [Data]
- baby: Relationship to Baby entity

## 技术实现细节

### 架构设计
- **MVVM模式**: 使用SwiftUI的声明式编程和Combine框架实现数据绑定
- **导航结构**: 基于TabView的标签式导航，支持深度链接
- **数据流**: Swift Data + SwiftUI环境对象实现响应式数据更新

### 核心组件
- **MainTabView**: 主标签导航容器
- **数据持久化**: Swift Data容器管理，支持数据迁移
- **图片处理**: 支持多种格式图片的存储和显示优化

## 开发状态跟踪
| 页面/组件名称 | 开发状态 | 文件路径 | 备注 |
|:-------------:|:--------:|:--------:|:----:|
| 应用入口 | ✅ 已完成 | `AiBaBy/AiBaByApp.swift` | 应用生命周期管理 |
| 主标签视图 | ✅ 已完成 | `AiBaBy/MainTabView.swift` | 标签导航容器 |
| 主页 | ✅ 已完成 | `AiBaBy/HomeView.swift` | 阿贝贝展示和管理 |
| 详情页 | ✅ 已完成 | `AiBaBy/BabyDetailView.swift` | 阿贝贝详细信息展示 |
| 编辑页 | ✅ 已完成 | `AiBaBy/BabyEditView.swift` | 阿贝贝信息编辑 |
| 记事本 | ✅ 已完成 | `AiBaBy/MomentsView.swift` | 生活记录展示 |
| 记事详情页 | ✅ 已完成 | `AiBaBy/MomentDetailView.swift` | 单条记录详细展示 |
| 记事编辑页 | ✅ 已完成 | `AiBaBy/MomentEditView.swift` | 生活记录编辑 |
| 设置页 | ✅ 已完成 | `AiBaBy/SettingsView.swift` | 应用设置和数据管理 |
| 分组管理 | ✅ 已完成 | `AiBaBy/Views/GroupManagementView.swift` | 阿贝贝分组功能 |
| 数据模型 | ✅ 已完成 | `AiBaBy/Models/BabyModel.swift` | Swift Data数据模型 |
| 头像组件 | ✅ 已完成 | `AiBaBy/Components/BabyAvatarView.swift` | 可复用头像组件 |
| 工具类 | ✅ 已完成 | `AiBaBy/Utils/AppColors.swift` | 应用颜色主题 |
| 图片选择器 | ✅ 已完成 | `AiBaBy/ImagePicker.swift` | 照片选择功能 |

## 项目结构

```
AiBaBy/
├── AiBaBy/
│   ├── AiBaByApp.swift          # 应用入口
│   ├── MainTabView.swift        # 主标签导航
│   ├── ContentView.swift        # 内容视图
│   ├── HomeView.swift           # 主页
│   ├── BabyDetailView.swift     # 阿贝贝详情页
│   ├── BabyEditView.swift       # 阿贝贝编辑页
│   ├── MomentsView.swift        # 记事本列表
│   ├── MomentDetailView.swift   # 记事详情页
│   ├── MomentEditView.swift     # 记事编辑页
│   ├── SettingsView.swift       # 设置页
│   ├── ImagePicker.swift        # 图片选择器
│   ├── Models/
│   │   └── BabyModel.swift      # 数据模型
│   ├── Views/
│   │   └── GroupManagementView.swift  # 分组管理
│   ├── Components/
│   │   └── BabyAvatarView.swift # 头像组件
│   ├── Utils/
│   │   └── AppColors.swift      # 颜色主题
│   ├── Extensions/              # 扩展文件夹
│   └── Assets.xcassets/         # 资源文件
├── AiBaByTests/                 # 单元测试
├── AiBaByUITests/               # UI测试
└── README.md                    # 项目说明
```

## 开发计划

### 已完成功能 ✅
- [x] 基础项目架构搭建
- [x] 数据模型设计与实现
- [x] 主要页面UI实现
- [x] 阿贝贝管理功能
- [x] 生活记录功能
- [x] 分组管理功能
- [x] 图片上传与显示
- [x] 应用大小优化
- [x] 代码重构与组件化

### 待优化功能 🔄
- [ ] 数据导入导出功能
- [ ] 云端同步支持
- [ ] 更多主题选择
- [ ] 数据统计分析
- [ ] 分享功能
- [ ] 无障碍访问支持