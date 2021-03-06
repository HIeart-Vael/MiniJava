# 用户手册

###### 7.1、软件说明

## 1、软件概述

本产品基于Xtext实现，运行于Eclipse IDE，实现了满足MiniJava语法规则的DSL（Domain-Specific Language）编辑器插件。该编辑器插件支持一般的MiniJava语言编写，语义检测、语法高亮、代码规格化、快速修复、项目管理等一般功能，还有Generator功能可以将MiniJava代码转换为Java代码等功能。

## 2、面向用户

产品面向大学编译原理教学、极客、技术宅、以及各种冷门软件开发爱好者。在使用时，用户可以毫无学习成本地在Eclipse IDE的新建向导中创建MiniJava的项目与文件，用户可以根据在Eclipse IDE中集成的功能窗口进行编码风格的定制化，更加贴合不同用户的使用习惯，并且可以对用户编写的代码进行语义检查与代码提示，结合快速修复、代码规格化等功能为用户编写代码提供便利。

## 3、主要特征

项目采用Xtext——基于文本的语言开发框架所开发，满足作为Eclipse插件发布的环境需求，在Eclipse IDE中加入了MiniJava项目和文件的新建向导，拥有可自定义的语法高亮功能，更加贴合不同用户的使用习惯，并且以MiniJava语法规则为原理对用户编写的代码进行语义检查与代码提示，结合快速修复、代码规格化等功能为用户编写代码提供便利。



###### 7.2、支持说明

## 1、运行环境

支持Windows系统、Linux系统环境下的的Eclipse开发平台

## 2、功能一览表

| **功能**                | **介绍**                                                |
| ----------------------- | ------------------------------------------------------- |
| 创建项目                | 在Eclipse新建向导中使用专门的选项创建MiniJava项目和文件 |
| 语法高亮                | 对不同类型的文本使用不同的颜色字体进行区分              |
| 语法语义检查            | 依照MiniJava语法规则检查用户的代码是否正确              |
| 代码大纲                | 对代码中的对象进行层次性整理                            |
| 快速修复                | 针对用户编写代码中可能出现的错误提供一键修复按钮        |
| 代码规格化              | 对不符合一般代码编写格式的代码按照设定模板进行规格化    |
| Generator               | 将MiniJava代码转化为Java代码，并调用Java编译器执行代码  |
| ContentAssist代码提示   | 为用户编辑的代码提供相应的提示信息                      |
| Interpreter表达式解释器 | 计算表达式的值并返回到编辑器中的代码提示栏中            |



###### 7.3、项目地址

[代码托管 - DevCloud (huaweicloud.com)](https://devcloud.cn-north-4.huaweicloud.com/codehub/project/11a409351928492aa1880f853e201633/codehub/prjcode)
