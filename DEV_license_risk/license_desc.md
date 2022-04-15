# 一、目的

公司在对内或对外发布的产品及服务中使用开源软件，需要遵守开源许可证的合规要求。为了帮助同学们识别合规义务，本文档列出了常用开源许可证、类型及基本合规要求。

# 二、适用

本文档适用于公司不拥有著作权的开源或第三方代码、二进制文件或数据（“代码”）等。

# 三、许可证合规基本要求

## ```
- 对外分发的软件中包含的开源软件应使用本部分2-4列出的许可证并履行合规义务。如果有问题，请联系opensource-legal@bytedance.com。   - 如使用本部分2-4节中未列明的许可证或者需要寻求许可证例外，参见第四部分《许可证合规评估流程》。  
```1. 不允许对外使用的许可证

表1列明了公司对外发布的软件或服务中不允许使用的许可证类型。这些许可证主要存在以下问题：不允许商用、许可证的条款模糊、许可证规定了公司难以遵守的义务等。

表1：

| **简称（SPDX-Identifier ）** | **全称或者子类别**                                  | 内部使用 | 外部使用：提供服务 | 外部使用：提供软件 | 说明                                                                   |
| ------------------------ | -------------------------------------------- | ---- | --------- | --------- | -------------------------------------------------------------------- |
| AGPL-3.0                 | GNU Affero General Public License v3.0       | √    | ×         | ×         | 1.  AGPL属于强互惠型许可证。-   如果可以通过远程网络接口访问产品或服务，触发开源义务。
-   在分发软件时,触发开源义务。 |
| SSPL-1.0                 | Server Side Public License, v 1              | √    | ×         | ×         | 1.  原因同AGPL。                                                         |
| CPAL-1.0                 | Common Public Attribution License 1.0        | √    | ×         | ×         | 1.  原因同AGPL。                                                         |
| EUPL-1.1                 | European Union Public License 1.1            | √    | ×         | ×         | 1.  原因同AGPL。                                                         |
| Commons Clause           | Commons Clause                               | ×    | ×         | ×         | 1.  本许可证不允许商用。
1.  很难争辩公司使用开源软件的行为不属商用。                              |
| Non-Commercial           | 具体包括：CC BY-NC, CC BY-NC-SA, CC BY-NC-ND      | ×    | ×         | ×         | 1.  此类许可证均不允许商用，
1.  很难争辩公司的任何行为不是出于商业目的。                            |
| SISSL                    | Sun Industry Standards Source License v1.1   | ×    | ×         | ×         | 1.  本许可证合规要求过于严格，很难满足。
1.  Sun也已经停止使用该许可证。                           |
| Watcom-1.0               | Sybase Open Watcom Public License 1.0        | ×    | ×         | ×         | 1.  专利限制太强：对Sybase或贡献者提起专利诉讼均会导致许可终止。                                |
| WTFPL                    | Do What The F*ck You Want To Public License | ×    | ×         | ×         | 1.  本许可证没有不担保条款。
1.  授权不清晰。                                          |

## 2. 限制型许可证，也称互惠型许可证

表2列明了在对外分发的客户端及嵌入式软件中不允许使用的许可证。如果独立程序中包含采用此类许可证的代码，依据许可证的要求，公司可能需要提供整个程序的源代码。

表2：

| **简称**                           | **全称或者子类别**                                           | 内部使用 | 外部使用仅提供服务 | 外部使用客户端 | 外部使用私有部署 | 关于○的说明                                                                                         |
| -------------------------------- | ----------------------------------------------------- | ---- | --------- | ------- | -------- | ---------------------------------------------------------------------------------------------- |
| CC-BY-SA                         | Creative Commons Attribution ShareAlike               | √    | √         | ×       | ○        | 采用此类许可证的组件如用于私有部署，需要经过批准：1.  该组件是否可以按照许可证的规定披露相关源代码给用户
1.  部署方式是否会导致其他组件承担开源义务。其他外部使用方式需要另行确认。 |
| CC-BY-ND                         | Creative Commons Attribution No Derivatives           | √    | √         | ×       | ○        |                                                                                                |
| GPL                              | GNU General Public LicenseGPL-1.0，GPL-2.0，GPL-3.0     | √    | √         | ×       | ○        |                                                                                                |
| GPL-2.0-with-classpath-exception | GNU General Public License v2.0 w/Classpath exception | √    | √         | ×       | ○        |                                                                                                |
| LGPL(静态链接)                       | GNU Lesser General Public LicenseLGPL-2.1，LGPL-3.0    | √    | √         | ×       | ○        |                                                                                                |
| NPL                              | Netscape Public LicenseNPL-1.0, NPL-1.1               | √    | √         | ×       | ○        |                                                                                                |
| OSL                              | Open Software License                                 | √    | √         | ×       | ○        |                                                                                                |
| QPL-1.0                          | Q Public License 1.0                                  | √    | √         | ×       | ○        |                                                                                                |
| Sleepycat                        | Sleepycat License                                     | √    | √         | ×       | ○        |                                                                                                |

## 3. 弱限制型许可证，也称弱互惠型许可证

表3列明了一些弱限制性的许可证。如果公司交付的软件中包含适用此类许可证的源代码，可能需要向软件接受方提供该源代码、相应的修改及添加。

表3：

| **简称**     | **全称或者子类别**                                              | 内部使用 | 外部使用 | 说明                                                            |
| ---------- | -------------------------------------------------------- | ---- | ---- | ------------------------------------------------------------- |
| CDDL-1.0   | Common Development and Distribution License 1.0          | √    | √    | 可能需要承担开源义务：一般而言，是库本身的内容，以及对该库的任何添加或修改。需要确认开源义务是否可以满足，再决定是否使用。 |
| CeCILL-2.0 | CeCILL Free Software License Agreement v2.0              | √    | √    |                                                               |
| CPL-1.0    | Common Public License 1.0                                | √    | √    |                                                               |
| EPL        | Eclipse Public LicenseEPL-1.0 and EPL-2.0                | √    | √    |                                                               |
| IPL-1.0    | IBM Public License v1.0                                  | √    | √    |                                                               |
| MPL        | Mozilla Public LicenseMPL-1.0, MPL-1.1, and MPL-2.0      | √    | √    |                                                               |
| APSL-2.0   | Apple Public Source License 2.0                          | √    | √    |                                                               |
| LGPL       | GNU Lesser General Public LicenseLGPL 2.1, LGPL-3 (动态链接) | √    | √    |                                                               |
| Ruby       | Ruby License                                             | √    | √    |                                                               |

## 4. 声明型许可证

表4中的许可证对公司分发的软件中的源代码没有限制，但是需要包含许可证中列明的“原始版权声明”或“广告条款”。

表4

| **简称**              | **全称或者子类别**                                                                           | 内部使用 | 外部使用 |
| ------------------- | ------------------------------------------------------------------------------------- | ---- | ---- |
| AFL                 | Academic Free LicenseAFL 2.1, AFL 3.0                                                 | √    | √    |
| Apache              | Apache LicenseApache-1.1 and Apache-2.0                                               | √    | √    |
| Artistic            | Artistic LicenseArtistic-1.0 and Artistic-2.0                                         | √    | √    |
| BSL-1.0             | Boost Software License 1.0                                                            | √    | √    |
| BSD-2-Clause        | BSD 2-Clause "Simplified" License                                                     | √    | √    |
| BSD-3-clause        | BSD 3-Clause "New" or "Revised" License                                               | √    | √    |
| BSD-2-Clause-Patent | BSD-2-Clause Plus Patent License                                                      | √    | √    |
| CC BY               | Creative Commons Attribution GenericCC-BY-1.0，CC-BY-2.0，CC-BY-2.5，CC-BY-3.0，CC-BY-4.0 | √    | √    |
| JSON                | JSON License                                                                          | √    | √    |
| EDL-1.0             | Eclipse Distribution License - v 1.0                                                  | √    | √    |
| FTL                 | Freetype Project License                                                              | √    | √    |
| ICU                 | ICU License                                                                           | √    | √    |
| ISC License         | ISC                                                                                   | √    | √    |
| LibTIFF             | libtiff License                                                                       | √    | √    |
| LPL 1.02            | Lucent Public License v1.02                                                           | √    | √    |
| MS-PL               | Microsoft Public License                                                              | √    | √    |
| Mulan PSL 2.0       | Mulan Permissive Software License, Version 2                                          | √    | √    |
| MIT/X11/Expat       | MIT License                                                                           | √    | √    |
| NCSA                | University of Illinois/NCSA Open Source License                                       | √    | √    |
| OpenSSL             | OpenSSL License                                                                       | √    | √    |
| PHP-3.0             | PHP License v3.0                                                                      | √    | √    |
| PIL                 | Python Imaging Library License                                                        | √    | √    |
| PostgreSQL          | PostgreSQL License                                                                    | √    | √    |
| PSF-2.0             | Python Software Foundation License 2.0                                                | √    | √    |
| TCP Wrappers        | TCP Wrappers License                                                                  | √    | √    |
| Unicode-DFS         | Unicode License Agreement - Data Files and Software                                   | √    | √    |
| UPL-1.0             | Universal Permissive License v1.0                                                     | √    | √    |
| W3C                 | W3C® SOFTWARE NOTICE AND LICENSE                                                      | √    | √    |
| XNet                | X.Net License                                                                         | √    | √    |
| zlib/libpng         | zlib License                                                                          | √    | √    |
| ZPL-2.0             | Zope Public License 2.0                                                               | √    | √    |

# 四、许可证合规评估流程

如果需要评估第三部分未列出的许可证，请联系邮件模板见下：

```
邮件标题为： [Confidential & Privileged]开源评估：关于[填入需要评估的软件]的评估

邮件正文需要列明：

1. 产品/项目及介绍文档： 

2. 评估需求：

3. 开源软件使用场景：客户端/服务端/前端/算法模型/私有部署

4. 开源软件的信息:

  - 名称：

  - 版本号：

  - 发布日期：

  - 开源协议名称及版本：

  - 官方地址：

  - Github地址：

  - 如该组件有依赖需要一并列出所有依赖的上述信息：
```

# 补充

## [声明型许可证 | Permissive Software License](https://en.wikipedia.org/wiki/Permissive_software_license)

对软件的使用、研究、修改和再发分上只有**最低需求(minimal restrictions)** ，常常只包含**免责声明(warranty disclaimer)** ，但这种许可证不保证派生版会继续保持自由软件形式。

与限制型许可证的区别：

1.  声明型许可证，衍生版本许可证可能变化，但要保留原始版权声明
1.  限制型许可证，需保持与原始许可证一致

> Copyleft licenses generally require the reciprocal publication of the source code of any modified versions under the original work's copyleft license. Permissive licenses, in contrast, do not try to guarantee that modified versions of the software will remain free and publicly available, generally requiring only that the original copyright notice be retained. As a result, derivative works, or future versions, of permissively-licensed software can be released as proprietary software.

> 限制型许可证普遍要求修改后的互惠型作品的源代码版本使用**相同**限制型许可证。作为对比，声明型许可证不保证修改后的软件版本保持自由和开放，只要求保留原始版权声明。因此限制型许可证下的软件，其衍生作品或者后期版本是可以闭源发布成专有软件的。

> [[Source](https://en.wikipedia.org/wiki/Permissive_software_license#Comparison_to_copyleft)]

|                                                                                       | **[MIT License](https://en.wikipedia.org/wiki/MIT_License)**                                                                                                                                                                                                                                                                                                               | **[Apache License](https://en.wikipedia.org/wiki/Apache_License)**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | **[BSD licenses](https://en.wikipedia.org/wiki/BSD_licenses)**                                                                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 简称**[SPDX](https://en.wikipedia.org/wiki/Software_Package_Data_Exchange)** ******ID** | MIT                                                                                                                                                                                                                                                                                                                                                                        | Apache-2.0Apache-1.1Apache-1.0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | BSD-3-ClauseBSD-2-Clause...                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|                                                                                       | 2021年前使用最多，目前top 2                                                                                                                                                                                                                                                                                                                                                         | 目前top 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 目前top 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 软件                                                                                    | [X Window System](https://en.wikipedia.org/wiki/X_Window_System), [Ruby on Rails](https://en.wikipedia.org/wiki/Ruby_on_Rails), [Nim](https://en.wikipedia.org/wiki/Nim_(programming_language)), [Node.js](https://en.wikipedia.org/wiki/Node.js), [Lua](https://en.wikipedia.org/wiki/Lua_(programming_language)), and [jQuery](https://en.wikipedia.org/wiki/JQuery) | [Apache Project List](https://www.apache.org/index.html#projects-list)[Apache HTTP Server](https://en.wikipedia.org/wiki/Apache_HTTP_Server), [Airflow](https://en.wikipedia.org/wiki/Apache_Airflow), [Hadoop](https://en.wikipedia.org/wiki/Apache_Hadoop), [Hive](https://en.wikipedia.org/wiki/Apache_Hive), [Spark](https://en.wikipedia.org/wiki/Apache_Spark), [Flink](https://en.wikipedia.org/wiki/Apache_Flink), [Kafka](https://en.wikipedia.org/wiki/Apache_Kafka)                                                                                            | [BSD licensed software](https://en.wikipedia.org/wiki/Category:Software_using_the_BSD_license)[Django](https://en.wikipedia.org/wiki/Django_(web_framework)), [Go](https://en.wikipedia.org/wiki/Go_(programming_language)), [D3.js](https://en.wikipedia.org/wiki/D3.js), [Chromium](https://en.wikipedia.org/wiki/Chromium_(web_browser)), [Celery](https://en.wikipedia.org/wiki/Celery_(software)), [Caffe](https://en.wikipedia.org/wiki/Caffe_(software)) |
| 公司/组织                                                                                 | [Microsoft](https://en.wikipedia.org/wiki/Microsoft) ([.NET Core](https://en.wikipedia.org/wiki/.NET_Core)), [Google](https://en.wikipedia.org/wiki/Google) ([Angular](https://en.wikipedia.org/wiki/Angular_(web_framework))), and [Meta](https://en.wikipedia.org/wiki/Meta_Platforms) ([React](https://en.wikipedia.org/wiki/React_(JavaScript_library)))           | **[Apache Software Foundation (ASF)](https://www.apache.org/)**![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/30338e44db2940afa99840fca03a6d24~tplv-k3u1fbpfcp-zoom-1.image)![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/23c13839aa314c78b3fc880c55c7c0f5~tplv-k3u1fbpfcp-zoom-1.image) | ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 备注                                                                                    |                                                                                                                                                                                                                                                                                                                                                                            | 很多非ASF的项目也是用Apache许可证，比如来自Linux Foundation中的项目                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | -   Go BSD-3-Clause + patent-   Chromium BSD and others                                                                                                                                                                                                                                                                                                                                                                                                                   |

**Bonus**：与Apache Software Foundation(ASF)影响力同样巨大的是[Linux Foundation(LF)](https://en.wikipedia.org/wiki/Linux_Foundation)，其陆续衍生出垂直领域的基金会，如[Cloud Native Computing Foundation(CNCF)](https://www.cncf.io/)、[LF Edge](https://www.lfedge.org/)、[LF AI & Data](https://lfaidata.foundation/projects/)、[GraphQL Foundation](https://graphql.org/foundation/)和近期才成立的[eBPF Foundation](https://ebpf.io/foundation)。

## [弱限制型许可证 | Weak Copyleft Software License | Weakly Protective Software License](https://en.wikipedia.org/wiki/Copyleft)

|                                                                                       | **[GNU Lesser General Public License](https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License)**                                                                                                                                                                                                                                                                                                                                                      | **[Mozilla Public License](https://en.wikipedia.org/wiki/Mozilla_Public_License)**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 简称**[SPDX](https://en.wikipedia.org/wiki/Software_Package_Data_Exchange)** ******ID** | LGPL-3.0+LGPL-3.0LGPL-2.1+LGPL-2.1LGPL-2.0+LGPL-2.0                                                                                                                                                                                                                                                                                                                                                                                                           | MPL-2.0MPL-1.1MPL-1.0...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 软件                                                                                    | [LGPL licensed software](https://en.wikipedia.org/wiki/Category:Software_using_the_LGPL_license)[7-Zip](https://en.wikipedia.org/wiki/7-Zip), [FFmpeg](https://en.wikipedia.org/wiki/FFmpeg), [GLib](https://en.wikipedia.org/wiki/GLib), [GTK](https://en.wikipedia.org/wiki/GTK), [Libheif](https://en.wikipedia.org/wiki/Libheif), [Qt](https://en.wikipedia.org/wiki/Qt_(software)), [VLC media player](https://en.wikipedia.org/wiki/VLC_media_player) | [MPL licensed software](https://en.wikipedia.org/wiki/Category:Software_using_the_Mozilla_license)[Bugzilla](https://en.wikipedia.org/wiki/Bugzilla), [Firefox](https://en.wikipedia.org/wiki/Firefox), [LibreOffice](https://en.wikipedia.org/wiki/LibreOffice), [Thunderbird](https://en.wikipedia.org/wiki/Mozilla_Thunderbird), [RabbitMQ](https://en.wikipedia.org/wiki/RabbitMQ), [Terraform](https://en.wikipedia.org/wiki/Terraform_(software)), [Eigen](https://en.wikipedia.org/wiki/Eigen_(C++_library)), [Brave Browser](https://en.wikipedia.org/wiki/Brave_Browser) |
| 公司/组织                                                                                 | [Free Software Foundation (FSF)](https://en.wikipedia.org/wiki/Free_Software_Foundation)![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2379382921544de680e70c949a69f99e~tplv-k3u1fbpfcp-zoom-1.image)                                                                                                                 | [Mozilla Foundation](https://en.wikipedia.org/wiki/Mozilla_Foundation)![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b6bb0e69613847c4af22e15221e1a4ed~tplv-k3u1fbpfcp-zoom-1.image)                                                                                                                                                                                                                                                            |

## [限制型许可证 | Strong Copyleft Software License | Strongly Protective Software License](https://en.wikipedia.org/wiki/Copyleft)

|                                                                                       | **[GNU General Public License](https://en.wikipedia.org/wiki/GNU_General_Public_License)**                                                                                                                                                                                                                                                                            | **[GNU Affero General Public License](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License)**                                                                                                                                                                                                   |
| ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 简称**[SPDX](https://en.wikipedia.org/wiki/Software_Package_Data_Exchange)** ******ID** | GPL-3.0-or-laterGPL-3.0-onlyGPL-2.0-or-laterGPL-2.0-onlyGPL-1.0-or-laterGPL-1.0-only                                                                                                                                                                                                                                                                                  | AGPL-3.0-or-laterAGPL-3.0-only...                                                                                                                                                                                                                                                                          |
| 软件                                                                                    | [GNU](https://en.wikipedia.org/wiki/GNU), [Linux kernel](https://en.wikipedia.org/wiki/Linux_kernel), [GCC](https://en.wikipedia.org/wiki/GNU_Compiler_Collection), [GIMP](https://en.wikipedia.org/wiki/GIMP), [VLC](https://en.wikipedia.org/wiki/VLC_media_player), [OpenJDK](https://en.wikipedia.org/wiki/OpenJDK), [GNOME](https://en.wikipedia.org/wiki/GNOME) | [AGPL licensed software](https://en.wikipedia.org/wiki/List_of_software_under_the_GNU_AGPL)[Anki](https://en.wikipedia.org/wiki/Anki_(software)), [BDB](https://en.wikipedia.org/wiki/Berkeley_DB), [Grafana](https://en.wikipedia.org/wiki/Grafana), [MongoDB](https://en.wikipedia.org/wiki/MongoDB)* |
| 公司/组织                                                                                 | [Free Software Foundation (FSF)](https://en.wikipedia.org/wiki/Free_Software_Foundation)![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/52e8ea9a2d414ec38580763e254fc574~tplv-k3u1fbpfcp-zoom-1.image)                         |                                                                                                                                                                                                                                                                                                            |
| 备注                                                                                    | VLC uses both weak and strong copyleft                                                                                                                                                                                                                                                                                                                                | *MongoDB dropped the AGPL in late-2018                                                                                                                                                                                                                                                                    |

### Weak & Strong Copyleft

1.  Copyleft许可证都要求衍生版本使用同样许可

1.  Strong Copyleft许可证要求衍生版本继续开源且使用同样许可

1.  Weak Copyleft许可证在特殊情况下可以不遵守上述第2条规定

    1.  LGPL应用在library上时，使用该库的软件可以是其他许可，不用跟着开源。（实际上LGPL中L最早为Library之意）
    1.  MPL只有现有文件的修改才需要使用同样许可

Broadly speaking, the scope of the MPL, LGPL, and GPL can be [summarized](https://www.mozilla.org/en-US/MPL/2.0/FAQ/) this way:

-   MPL: The copyleft applies to any files containing MPLed code.

<!---->

-   LGPL: The copyleft applies to any library based on LGPLed code.

<!---->

-   GPL: The copyleft applies to all software based on GPLed code.