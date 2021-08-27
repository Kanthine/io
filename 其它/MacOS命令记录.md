# MacOS命令记录

####

* `ls` : 显示当前文件下的所有目录
* `ls -alt` : 显示当前文件下的所有目录，按倒序排列
* `cd` : 进入到某个目录下
* `cd ..` : 回退到上一级目录
* `pwd` : 查看当前位置
* `mkdir` : 创建一个目录
* `cp` : 拷贝一个文件
* `rm` : 删除文件或目录
* `sudo` : 切换当前用户权限 
* `control+l` : 清屏
* `pkg-config` : 链接库文件




```
/// 创建 1.txt ； 并将字符串 ‘你好’ 输入到该文件 
MacBook-Pro Desktop % echo "你好" >> 1.txt

/// 查看文件内容
MacBook-Pro Desktop % cat 1.txt 
你好

/// 删除文件
MacBook-Pro Desktop % rm 1.txt 

/// 删除目录: -rf 强制删除
MacBook-Pro Desktop % rm -rf 111
```



##### `vim` 基本命令

[ `vim` 基本命令](https://www.runoob.com/linux/linux-vim.html) :

* `i` 进入编辑模式；
* `:w` 保存文件；
* `:q` 退出文件；
* `:wq` 退出并保存文件；


##### `Linux` 中的环境变量

* `PATH` : 在 `PATH`  中指定一个路径，则该路径为全局的！
* `PKG_CONFIG_PATH` :
* `~/.bash_profile` : ，当前用户目录下，环境变量的变更；
* `source ~/.bash_profile` : 保存更新环境变量
* `env` : 查看当前环境变量
* `env | grep PATH` : 查看环境变量

`PKG_CONFIG_PATH`  与 `LD_LIBRARY_PATH`  的区别？

```
/// 环境变量的路径设置
MacBook-Pro % vi ~/.bash_profile

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/ffmpeg/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/local/Cellar/x264/r3049/lib/pkgconfig/:/usr/local/Cellar/openssl@1.1/1.1.1k/lib/pkgconfig/:
export PATH=/usr/local/ffmpeg/bin:$PATH
export PATH=/usr/local/Cellar/x264/r3049/lib/libx264.a:$PATH

/// 修改立即生效
MacBook-Pro %  source ~/.bash_profile

/// 查看环境变量的值
MacBook-Pro % echo $PATH

```

```
///将相关 ffmpeg 文件拷贝至 App 文件夹中
cp -r /usr/local/ffmpeg/include/* ./include/
cp -r /usr/local/ffmpeg/lib/* ./libs/
```


参数选项 | 功能说明
- | -
`-i` | 设定输入流
`-f` | 设定输出流
`-ss` | 开始时间
`-t` | 时间长度
`-aframes` | 设定要输出的音频帧数
`-b:a` | 音频码率
`-ar` | 设定采样率
`-ac` | 设定声音的 `channel` 数
`-acodec` | 设定声音编解码器，如果采用 copy 表示原始编解码数据必须被拷贝
`-an` | 不处理音频
`-af` | 音频过滤器
`-vframes` |  设定要输出的视频帧数
`-b` | 设定视频码率
`-b:v` | 视频码率
`-r` | 设定帧速率
`-s` | 设定画面的宽与高
`-vn` | 不处理视频
`-aspect aspect` | 设定横纵比
`-vcodec` | 设定视频编解码器，如果采用 copy 表示原始编解码数据必须被拷贝
`-vf` | 视频过滤器







```
/// 弊端：后期无法使用其工具
brew install ffmpeg

/// 网上下载源码，然后编译
///  --enable-libx264 --enable-gpl 使用 x264 对视频编码时用得到
./configure --prefix=/usr/local/ffmpeg --enable-debug=3 --disable-static --enable-shared
./configure --prefix=/usr/local/ffmpeg --enable-debug=3 --disable-static --enable-shared --enable-libx264 --enable-gpl --enable-pthreads
./configure --prefix=/usr/local/ffmpeg --enable-debug=3 --disable-static --enable-shared --enable-swscale --enable-gpl --enable-nonfree --enable-pic --enable-postproc --enable-pthreads --enable-libx265 --enable-libx264 --enable-libfdk-aac --disable-x86asm
make -j 4 ///开4个线程处理事件
./configure --enable-x86asm --prefix=/usr/local/ffmpeg
make install
```

