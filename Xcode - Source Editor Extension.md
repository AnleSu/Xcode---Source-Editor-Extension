# Xcode - Source Editor Extension

看到这个标题，不知道大家会不会有些陌生，那如果说**xcode plugin**是不是会熟悉一些，就是xcode的三方插件。做过几年的iOS开发，肯定对插件还是有印象的，虽然也是个历史了。在Xcode8之前，我们可以使用各种各样的插件，之后苹果就不再支持三方插件了，但是提出了一个新的解决方案----**Xcode - Source Editor Extension**，就是我们本文要讨论的内容了，就叫他扩展吧，后面文章里也都叫扩展。



由此可见，扩展这个技术也已经被提出很久了，本文就一起来探索一下，这个技术能为xcode扩展什么样的功能。我也是最近抽空研究写了一个小demo，看的还比较浅显，如果正在看文章的你有什么新的见解，欢迎评论区讨论呢。



# 简介

苹果在WWDC的session中有介绍Source Editor Extension，下面我简单总结一下它的功能，其实提供的接口很少，我们可做的事也不多，局限性也多，和之前辉煌的三方插件，差距还是很大的。



一个插件主要可以做下面几件事：

1. 获取Xcode中正在编辑（或选中）的文本
2. 替换Xcode中正在编辑（或选中）的文本
3. 在Xcode - Editor中生成一个插件的子菜单
4. 可以给插件分配一个快捷键



# 创建一个Extension

下面主要记录一下，创建一个Extension的详细步骤，如果你有想法自己开发一个插件，那下面的文章，会是一个不错的踩坑记录~ 希望可以帮到你。

 

## 创建一个Mac OS 项目

File --- New --- Project --- macOs --- APP

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108140320052.png" alt="image-20210108140320052" style="zoom: 33%;" />

## 添加一个Source Editor Extension

File --- New --- Target --- macOs --- Xcode Source Editor Extension

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108140508980.png" alt="image-20210108140508980" style="zoom: 33%;" />

或者如下操作，也可以添加一个extension

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108140700346.png" alt="image-20210108140700346" style="zoom: 33%;" />



最后会有个弹框提示，点击选择**Active**就可以了。



最终，工程的结构也是如上图所示，**这里注意会有两个scheme，后续都是运行和调试extension对应的scheme。**

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108140846786.png" alt="image-20210108140846786" style="zoom:50%;" />

## 开始你的表演

工程创建好了，下面就可以开始你的表演了，插件能做的事不算太多，所以这是个头脑风暴的时候，你觉得可以做那些提高开发效率的工具呢~



下面会以我自己开发的一个小工具为例，主要是为了展示插件的开发流程和注意事项，这个工具在你的项目中不一定适用，如果也可以适用的话，欢迎参考。



### 工程配置

主要的配置都在info.plist中，上面强调过，后续所有的开发都针对extension，不要改错位置了。

```
<key>NSExtension</key>
	<dict>
		<key>NSExtensionAttributes</key>
		<dict>
			<key>XCSourceEditorCommandDefinitions</key>
			<array>
				<dict>
					<key>XCSourceEditorCommandClassName</key>
					<string>SourceEditorCommand</string>
					<key>XCSourceEditorCommandIdentifier</key>
					<string>$(PRODUCT_BUNDLE_IDENTIFIER).SourceEditorCommand</string>
					<key>XCSourceEditorCommandName</key>
					<string>LocalTool</string>
				</dict>
			</array>
			<key>XCSourceEditorExtensionPrincipalClass</key>
			<string>SourceEditorExtension</string>
		</dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.dt.Xcode.extension.source-editor</string>
	</dict>
```



`XCSourceEditorCommandDefinitions`是设置每个Extension的基础信息的，`XCSourceEditorCommandClassName`是处理这个扩展的类名，`XCSourceEditorCommandIdentifier`是每个扩展的唯一标识，用于和别的扩展做区分，`XCSourceEditorCommandName`就是最后显示在Editor菜单中的名字。



如果我们工程里只需要开发一个扩展，那只要更改`XCSourceEditorCommandName`这一项就可以，其他都用默认配置。

### 编写扩展代码

工程中，自动生成了两个类，SourceEditorExtension和SourceEditorCommand，这两类名，在刚才的plist配置文件中也出现了，后面的核心代码都写在这两个类中。

SourceEditorExtension这个类，我理解主要是做关于扩展的生命周期的控制。



SourceEditorCommand中，可以获取到Xcode正在编辑的文本内容，这里我们可以做相应的替换工作。只有performCommandWithInvocation这么一个核心的方法，下面是获取正在编辑文本内容的代码。

```
- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
	 XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    NSInteger lineNumber = selection.start.line;
//    xcode中选中的行
    NSString *text = invocation.buffer.lines[lineNumber];
    NSLog(@"选中行的内容%@",text);
    // 要替换的内容
    NSString *result = ...
    [invocation.buffer.lines replaceObjectAtIndex:lineNumber withObject:result];
}
```



### 调试

选择扩展对应的scheme运行，选择Xcode， 就会弹出一个灰色的Xcode界面，这里可以打开已有项目，或者新建测试项目

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108143711424.png" alt="image-20210108143711424" style="zoom:33%;" />

然后在Editor菜单栏中就可以看到我们刚才改过名字的扩展名称了，到这里插件的整个开发流程完成。

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108143948317.png" alt="image-20210108143948317" style="zoom:50%;" />

### 实践和踩坑

我自己做了一个多语言的注释工具，作为一次插件的实践，下面分享一下他的功能和实现思路。



相信很多小伙伴公司的项目，都有用到多语言开发，这里就不过多介绍了，我做的这个小扩展，就是用来给多语言代码加注释用的，比如多语言被用在条件语句中，可读性会比较差，这时我们要全局搜索，找到string文件中对应的内容添加注释，过程比较麻烦。

```
"KNOW"   = "知道了";
"CANCEL" = "取消";
"DONE"   = "完成";
"OK"     = "确定";
```



下面我们通过扩展来为多语言代码 一键添加注释：



<video src="/Users/suanle/Desktop/屏幕录制2021-01-08 下午3.15.19.mov"></video>



#### 思路

1. 从XCSourceEditorCommandInvocation中提取当前Xcode中正在编辑的行的内容
2. 从中截取出多语言编码用到的那一段 ，即"KNOW"
3. 获取多语言文件路径 ， 即xxx.strings文件的路径
4. 读取xxx.strings的内容
5. 用"KNOW"去做匹配，取到里面对应的中文注释，即"知道了"
6. 把"知道了"作为注释，拼接在原来编辑行的内容后面
7. 替换还有文本内容
8. 结束

#### 用到的技术点

1. 字符串截取或者使用正则匹配
2. NSFileManager的使用

#### 踩坑

最深的一个坑就是：证书！！！！

```
IDEExtensionManager: Xcode Extension does not meet code signing requirement: com.sal.SourceEditorExtensionTest.LocalTool (file:///Users/xxxxx/Library/Developer/Xcode/DerivedData/SourceEditorExtensionTest-bltqsxwfdzxeirceowbwjuzaxpjd/Build/Products/Debug/SourceEditorExtensionTest.app/Contents/PlugIns/LocalTool.appex/), Error Domain=DVTSecErrorDomain Code=-67050 "code failed to satisfy specified code requirement(s)" UserInfo={NSLocalizedDescription=code failed to satisfy specified code requirement(s)}
```

报这个问题就是因为证书签名**，一定要把这两个target对应的证书，provisioning profile部分整明白了才行**。

<img src="/Users/suanle/Library/Application Support/typora-user-images/image-20210108153119289.png" alt="image-20210108153119289" style="zoom:50%;" />



其他的没有啥大问题，属于做这个项目的业务问题了，获取当前xcode的路径：

1. 系统设置里的扩展
2. Info.plist里声明需要发送Apple Events：Privacy - AppleEvents Sending Usage Description， 类似于获取相机或者定位权限，这一步向系统声明需要执行Apple Script，当第一次执行插件的时候，系统会弹窗给用户来获取权限
3. 沙盒.entitlements文件里，配置com.apple.security.temporary-exception.apple-events，内容是com.apple.dt.xcode和com.apple.dt.document.workspace，声明我们需要例外，来控制Xcode
4. 如果你之前在第二步——获取权限提示的时候，不小心点了否，或者因为前三个没有配，系统默认帮你点了否，那么就是最糟糕的了——需要重置AppleEvents的提示：在命令行输入tccutil reset AppleEvents

如果你配置了上面这4项，就可以成功执行Apple Script，那么Xcode extension的能力，会得到极大提高。


### 传送门
本文分享的实践代码------> [点这里](https://github.com/AnleSu/Xcode---Source-Editor-Extension.git)


## 文献

https://medium.freecodecamp.org/how-to-convert-your-xcode-plugins-to-xcode-extensions-ac90f32ae0e3