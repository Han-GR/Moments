# AiBaBy (AiBaby)

## 项目概述
AiBaBy（AiBaby）是一款帮助用户管理自己的"阿贝贝"的iOS应用。在现代社会，很多人会有多个"阿贝贝"并将它们视为自己的孩子，这款应用旨在提供一个平台让用户可以记录和管理这些特别的存在。

## 目标用户
所有拥有"阿贝贝"并希望记录它们生活点滴的用户。用户可能将这些"阿贝贝"视为自己的孩子，希望有一个专门的平台来保存相关记忆。

## 技术选型
- 开发框架: SwiftUI
- 数据持久化: Core Data
- 状态管理: Combine与SwiftUI原生状态管理
- UI风格: 遵循iOS Human Interface Guidelines (HIG)，采用暗色科技风现代简约设计

## 应用结构
应用采用标签式导航结构，主要包含以下几个主要部分：
- 主页：展示所有的"阿贝贝"
- 详情页：查看单个"阿贝贝"的详细信息
- 编辑页：添加或编辑"阿贝贝"的信息
- 记事本：记录关于"阿贝贝"的生活瞬间

## 页面结构

| 页面/视图名称 | 用途 | 核心功能 | 技术实现 | 导航/用户流程 | 建议文件路径 |
|:--------:|:----:|:--------:|:--------:|:--------:|:--------:|
| 主页 | 展示所有阿贝贝 | 网格/列表展示所有阿贝贝，支持搜索和筛选 | SwiftUI List/Grid, Core Data | 应用启动首页，点击进入详情页 | `AiBaBy/HomeView.swift` |
| 详情页 | 展示单个阿贝贝的详细信息 | 显示照片、基本信息、生活记录 | SwiftUI, Core Data | 从主页点击进入，可跳转到编辑页 | `AiBaBy/BabyDetailView.swift` |
| 编辑页 | 添加/编辑阿贝贝信息 | 上传照片，编辑名字、生日等信息 | SwiftUI Form, Image Picker | 从详情页或主页的添加按钮进入 | `AiBaBy/BabyEditView.swift` |
| 记事本 | 记录阿贝贝的生活瞬间 | 添加、编辑、删除生活记录 | SwiftUI, Core Data | 从详情页进入或通过标签栏访问 | `AiBaBy/MomentsView.swift` |
| 设置页 | 应用设置 | 主题切换、数据备份、通知设置 | SwiftUI, UserDefaults | 通过标签栏或主页设置按钮访问 | `AiBaBy/SettingsView.swift` |

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

## 开发状态跟踪
| 页面/组件名称 | 开发状态 | 文件路径 |
|:-------------:|:--------:|:--------:|
| 主页 | 未开始 | `AiBaBy/HomeView.swift` |
| 详情页 | 未开始 | `AiBaBy/BabyDetailView.swift` |
| 编辑页 | 未开始 | `AiBaBy/BabyEditView.swift` |
| 记事本 | 未开始 | `AiBaBy/MomentsView.swift` |
| 设置页 | 未开始 | `AiBaBy/SettingsView.swift` |
| 数据模型 | 未开始 | `AiBaBy/Models/BabyModel.swift` |