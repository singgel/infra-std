## 概述

-   目的
-   阶段
-   标准
-   看什么&怎么看&速度
-   怎么写comments
-   如何处理pushback
-   如何处理comments
-   如何评价

## 目的

```
The primary purpose of code review is to make sure that the overall code health of Google’s code base is improving over time.
```

代码审查的主要目的是确保代码库的总体代码质量随着时间的推移而不断改善。

提升代码质量，减少低级错误

提升服务稳定性，SDK交付质量

提升个人技术水平

对齐团队代码规范

## 阶段

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/533b52a996d24920975cba44fad4e36d~tplv-k3u1fbpfcp-zoom-1.image)

### 常见问题：

1.  技术评审无法落地，想法很丰满，落地很骨感。
1.  技术规范多而杂，并且可读性差，维护的不好，实施不到位。
1.  Code review不够正式，即使发现问题也会以“时间不够”为由给忽略掉。
1.  经验积累不下来，同样的错误反复去犯，挤压了寻求更高代码质量的时间和空间。

## 名词说明

-   **mr: merge request**

<!---->

-   **cr: code review**

<!---->

-   **cl: change list，指这次改动**

<!---->

-   **reviewer: cr的被邀请人**

<!---->

-   **nit: 全称nitpick，意思是鸡蛋里挑骨头**

<!---->

-   **作者: 也就是本次CL的开发者**

## Standard/标准

### Trade-offs/权衡

1.  站在开发者的角度，**开发者需要能够有所进展**

    1.  如果Reviewer对于任何改动都卡的过于严格，则开发者则会失去提交代码的兴趣
    1.  如果开发者从来不往code base里提交任何改动，那么代码质量不会变好

1.  站在Reviewer的角度，**Reviewer需要保证每个** **MR** **的质量**，防止code base的code health在长期下降

    1.  然而大多数情况下，code base的劣化是一个一个MR的小小劣化累积起来的
    1.  并且开发者的理由是“排期很紧，迅速上线，后续再优化”

### Senior Principle/根本原则

**In general, reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system being worked on, even if the CL isn’t perfect.**

一般情况下，如果一个MR已经达到了能够提升整体代码质量的程度，即使不完美，也应该倾向于同意合入。

不要在MR中追求完美，因为不存在‘完美’的代码，只存在‘更好’的代码。Reviewer应该追求的是‘持续的改进’而不是‘完美’。

当然，Reviewer可以随意评论一些他认为觉得不影响的细节，使用‘Nit:’开头。

注意：**但这并不意味着Reviewer应该接受让code health下降的代码，唯一的例外是发生紧急事故需要立刻止损。**

### Mentoring/指导

Code review能够很好的帮助开发者学会一些新的语言特性、新的框架使用方法、良好的编程规范、优秀的架构设计等等。**我们鼓励Reviewer留下一些纯教育性的comment在MR上**，因为分享知识对于提升code health非常重要。如果这些comment不需要强制解决的话，请以‘Nit:'作为开头来标记。

### Principles/原则

1.  **技术事实和数据 >> 个人意见和偏好**
1.  **对于Style来说，按照文档作为唯一权威，如果文档上没有显示说明，则接受Author的写法**
1.  **代码设计的问题，从来不是简单的代码风格或者个人偏好的问题，而是基于一些基本的代码设计原则。如果Author能够证明有多种不同实现，并且（依据基本代码设计原则或者数据）彼此等效，那么Reviewer应该接受Author的偏好。否则的话，应该服从基本代码设计原则。**
1.  **如果相关代码找不到对应的rule，那么Reviewer可以要求Author和code base中已有的代码保持一致，但是前提是这个保持一致不会让整体code health变糟糕。**

### Resolving Conflicts/解决冲突

当Reviewer和Author意见冲突的时候，第一件事则是通过各种**手册规范**，试图达成共识。

如果无法达成共识遇到困难的话，不建议继续在comment区里你来我往，而是**当面或者视频**进行交流。记得将结果同步到comment区方便后面的读者。

如果还是无法达成共识，可以将**问题升级**，让架构组加入讨论，或者在团队内进行讨论，或者找代码的维护者征询意见。不要因为意见冲突就把mr放置不合入。

如果最终解决不了，决定权应该是代码的维护者。

## What to look for/看什么

### Design/设计

和**技术评审**的实现是否一致？

这个功能是否应该属于这个模块？

### Functionality/功能

实现是否能够达到Author的意图？

Edge case/异常处理/Race condition等有没有考虑到？

是否有肉眼可见的bug？

### Complexity/复杂性

代码是否容易阅读？

代码行数、方法入参、class接口是否过多？

在使用或者修改这段代码的时候是否容易出错？

是否过度设计？

### Tests/测试

是否能涵盖新功能？

当代码真的有问题，测试是否会失败？

确保测试是正确、合理、有用的

### Naming/命名

命名是否科学？

### Comments/注释

是否有必要的注释？是否有不必要的注释？

已有的注释是否需要更新或者删除？（TODO被完成了、代码情况变化了）

```
通常来讲，注释应该描述的是代码无法表达的东西，譬如描述这一段代码为什么存在，而不是这段代码在干什么。这段代码在干什么，应该能轻易的从代码里读出来，否则的话，则需要让代码更简单。
```

### Style/风格

**严格**按照Code Style**规范**。如果是个人偏好不在规范上，需要加上‘Nit:’告诉Author这并非强制。

大规模的style change不应该混在一个MR里提交，否则代码阅读和merge会非常困难。如果要reformat整个文件，需要单独提交一个mr。

### Documentation/文档

注意，和comments不同，documentation通常作用于module，class，method，用来表述这段代码的作用，如何使用，以及使用时的不同行为。

对于Service来说，**所有的接口**都应该有documentation。

### Every Line/每一行

要确保**每一行**代码都看过并且知道代码在干什么。

虽然有些代码比另一些代码更需要仔细检查，但是也不要看到方法名或者类名，就假设这个代码是如何实现的。

如果你发现有代码**无法轻易看懂**，那么很有可能别的工程师也看不懂，这个时候不要浪费大量时间去死磕代码，而是找Author来解释清楚代码的意图，或者**让代码更加简单**，或者**加上注释和文档**，帮助后面的阅读者。

如果你能看懂代码，但是却觉得自己没有能力对某些代码干的事情负责，那么一定要带上有**相关经验**（譬如启动速度相关、feed相关、或者别的组的复杂的业务逻辑）的人作为reviewer。

### Context/上下文

不要只看代码改动的那几行，多**展开整个方法或者类**，或者**站在系统设计的角度上**看问题。要记住，我们的最终目标，是保证整个code base的code health不会因为这个mr下降。

### Good Things/优点

如果你喜欢某个MR中的一段代码，尤其是当Author非常好的解决了你的某个comment，记得在评论里**表达赞赏**。因为code review主要是聚焦在mistakes上，会给Author较大压力。我们希望code review也能够帮助到Author，并且形成一种正向激励。
## Navigating MR / MR导航

### 粗略Review全貌

看一眼相应的链接：**需求文档/技术评审/Bug链接**。

然后快速评估：

这个改动合理吗？有没有方向性错误？（通常来说不应该，否则说明技术评审阶段有重大问题）

有没有满足合入的前置条件？（需求在封板之后合入？大改动在发版前合入？SDK升级有没有附上对应的评审文档？）

```
如果发现重大的设计问题，立即留下comment，不用浪费时间继续review剩余的代码，因为设计问题影响的面足够大，即使你review完，大部分代码也会消失 。
```

### 仔细Review重点

如果代码过多，难以找到重点，可以询问Author应该重点看哪里。

### 快速Review剩下的

请**不要跳过**任何一行。

## Speed of Code Reviews

### Why Should Code Reviews Be Fast?

影响需求上车，降低团队迭代速度

开发者有意见，反对code review流程

Code health受到影响，大家工期变紧张，提交代码成本变高，不愿意去优化现有代码。

### Fast Responses

总的来说个人回应评论的速度，比起让整个cr过程快速结束来得更为重要。即使有时需要很长时间才能完成整个流程，但若在整个过程中能快速获得来自reviewer的回应，这将会大大减轻开发人员对于缓慢的cr过程的挫败感。

如果真的忙到难以抽身而无法对CL进行全面review时，你依然可以快速的回应让开发者知道你什么时候会开始审核、建议其他能够更快回复reviewer，又或者提供一些初步的广泛评论。(注意:这并不意味着你应该中断开发去回复——请找到适当的中断时间点去做)

理想的个人的回应速度还是越快越好。

### How Fast Should Code Reviews Be?

最慢一天（半天？）。早晨、午饭、晚饭后第一件事。

### Large CLs

如果有人要求reivew时，但由于改动过于庞大导致你难以确定何时才有时间review它时，你通常该做的是要求开发人员将CL拆解成多个较小的CL，而不是一次review巨大的CL。这种事是可能发生的，而且对于reviewer非常有帮助，即便它需要开发人员付出额外人力来处理。

一个MR最好是一个能单独交付的最小feature

如果CL无法分解为较小的CL，且你没有足够时间快速查看整个CL内容时，那么至少对它的整体设计写些评论，并发送回开发人员以便进行改进。身为reviewer，你的目标之一是在不牺牲代码质量的状况下，避免阻挡开发人员进度，或让他们能够快速采取其他更进一步的动作。

### LGTM With Comments(Approve)

LGTM(Looks Good To Me)意味着代码符合要求，可以合入。

如果LGTM里带有一些comments，那么说明:

5.  Reviewer相信Author能够正确的修复comments，不需要再次review
5.  或者这些comments不是很重要，并且不是必须得Author去提交。

### Code Review Improvements Over Time/cr的能力会随着时间进步

如果我们**严格遵守**review标准的话，**长期**看来，我们的code review流程会**越来越快**，因为大家慢慢都了解如何写好高质量代码，很多MR从一开始看上去就是很不错的。

然而，如果我们为了追求短期流程快，而去降低标准的话，长期看来反而不会加速整个流程。

### Emergencies/紧急情况

紧急情况下，对MR的code review可以适当放松标准，让其快速通过。但是Emergencies的界定需要非常的严格，决定权交给代码和项目负责人。

## How to write code review comments

### Courtesy/礼貌

就事论事，就码论码，记得**保持风度**。

### Explain Why/解释为什么

解释为什么有comment，帮助Author理解问题并且解决问题。

### Giving Guidance/给予指导

一般来说，Reviewer没有责任去修复一个MR。因为Author通常更加熟悉实际的代码，指出问题后，把修复方案的决定权交给Author，往往效果更好。

但是根据具体情况，Reviewer可以适当的给予指导、解决方案，甚至直接提供代码。我们的首要目标是更好的MR的质量；其次才是提高Author的技能和水平。

### Accepting Explanations/接受说明

如果你看不懂某一段代码，通常会有两种解决方案：

7.  Author**重写**代码，让其更加易懂
7.  Author在**代码上**加上必要的**comment**和**Documentation**（在这段代码本身不复杂的情况下）

尽量不要在comment里进行代码的解释，因为这无意于后来的读者。除非这段代码逻辑广为人知，只是reviewer不熟悉。

## Handling pushback in code reviews/处理代码审查中的冲突

有时候Author会对code review中提出的comment进行pushback。要么是因为他不同意你的建议，要么是因为他觉得你在code review中过于严格。

### Who is right?

当发生pushback的时候，一定要思考，对方给的理由是不是有道理。有时候对方会给出一个相当不错的解释，那这个时候是可以接受的。但是Author并不一定总是正确的。如果Reviewer坚信这个改进能够提高代码质量，那他应该坚持己见，并且给出更加详细的解释。

**水滴石穿，聚沙成塔**（**Improving code health tends to happen in small steps.）**

### Upsetting Developers

Reviewer有时候会担心，坚持某项improvement会激怒对方。

通常事后对方会感到感激，因为你的坚持帮助他提升了code health。但是注意comments的写法和语气也是很重要的。

### Cleaning It Up Later

Author想要早点把代码合进去，所以经常会说稍后提MR修复，让你给他点击review通过。

然而从经验上来说，离这个MR时间越久，Author会提交一个MR去修复这个问题的概率越低。事实上，除非在MR合入之后立即提交一个MR修复，不然这种事情从来不会发生。这并不是因为开发者不负责任，只是因为他太忙了，这些事情很快就会被遗忘在大量的工作中，再也不会被想起。

因此，**最好**在MR中坚持这些问题**必须**被修复。code base劣化通常就是因为一个一个的‘稍后修复’。如果要修复这个问题需要比较高的复杂度，没有办法在当前MR修复，那么**一定**要提一个Bug或者技术需求，指向Author，甚至在代码的注释中写一个TODO，指向那个bug链接，来保证这些问题最后**不会被跟丢**。

### General Complaints About Strictness/有关严格性的一般投诉

如果code review之前非常的松垮，突然切换到严格的code review的时候，开发者通常会持续的抱怨新的code review。这种抱怨，通常会随着code review的速度越来越快而慢慢消失，但是我们预期可能会持续若干个月。

当code review确实见效之后，那些抱怨的最大声的人，可能就成为了你最坚定的拥护者，因为他们清晰的感受到了code review对他们的帮助和转变。
## How to handle reviewer comments

### Don’t Take it Personally

就事论事，就码论码。碰到comments的时候，思考对方究竟想和自己表达什么，以及comment是否具有建设性。

### Fix the Code

如果Reviewer告诉你有段代码他看不懂，那么第一反应，是将代码简化，写得更加清晰；如果代码没有办法再简化了，那就写一段comment；如果这个comment写的毫无意义，最后才应该在comment下面进行直接回复。

### Think for Yourself

自己辛辛苦苦写了几天的代码，并且事先好好打磨过了，在看到reviewer依然能够挑出毛病来，通常来说是很难接受的。

但是，不管你多么认为自己是对的，你的第一反应还是应该是：“Reviewer说得对不对？”

如果你不确定，那么reviewer可能需要让comment更加清晰；

如果你认真考虑了并且觉得自己还是对的，可以好好解释一下，为什么你的代码能够提高code base的health。因为通常来说，reviewer只是给你提供建议，他们希望你自己去思考，到底怎么做对code base是最好的。通常最后你都能和reviewer达成一致。

如果无论如何都无法达成一致，请参照上面的**Resolving Conflicts**章节。

## 理想的状态：

1.  代码的内容有人详细的看过，并且能够对此负责。
1.  效率高，只占用所需要的最少的精力。
1.  发现的质量问题能够落地修复，并且经验能够积累。

## 形式

-   线上提交，异步review

<!---->

-   review会议

## 评价

-   怎么评价code review效果

<!---->

-   月度总结，case分析