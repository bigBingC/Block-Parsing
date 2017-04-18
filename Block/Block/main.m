//
//  main.m
//  block
//
//  Created by 崔冰 on 2017/4/11.
//  Copyright © 2017年 崔冰. All rights reserved.
//

#import <Foundation/Foundation.h>

//https://juejin.im/post/58f40c0a8d6d810064879aaf

int b = 3;           //全局变量
static int d = 11;   //全局静态变量

//全局变量，可以直接访问。
//静态全局变量，可以直接访问。
//静态变量，直接指针引用。
void test1(){
    static NSString *str = @"q"; //静态变量
    
    void(^block)() = ^{
        b = 12;
        d = 23;
        str = @"w";
        NSLog(@"test1==== %d %d %@",b,d,str);
    };
    
    block();
    
    //全局变量和全局静态变量没有被截获到block里面，它们的访问是不经过block的
    //访问静态变量（static_val）时，将静态变量的指针传递给__main_block_impl_0结构体的构造函数并保存
}

void test2(){
    
    NSMutableArray *mutArr = [NSMutableArray array];
    NSString *str = @"1";
    int a = 1;
    void (^block)() = ^{
        //       str = @"2";
        //       a = 2;
        [mutArr addObject:@"w"];
        //局部变量一旦被Block保存，在Block内部就不能被修改了.这里的修改是指整个变量的赋值操作，变更该对象的操作是允许的，比如在不加上__block修饰符的情况下，给在block内部的可变数组添加对象的操作是可以的
        
        NSLog(@"test2==== %@ %d %@",str,a,mutArr);
        
    };
    a = 3;
    str = @"4";
    block();
    
    //这两个变量是值传递，而不是指针传递，也就是说Block仅仅截获自动变量的值，所以这就解释了即使改变了外部的自动变量的值，也不会影响Block内部的值
}

void(^block1)(NSString *str,int a) = ^(NSString *str,int a){
    
    NSLog(@"test3==== %@ %d",str,a);
    
};

void test3(){
    NSString *str = @"q";
    int a = 1;
    block1(str,a);
    str = @"s";
    a = 2;
    //全局block也是一样的
}

void test4(){
    __block int a = 3;
    __block NSString *str2 = @"w";
    void (^block)() = ^{
        a = 2;
        NSLog(@"test4==== %d %@",a,str2);
    };
    str2 = @"b";
    block();
    
    //block的作用： block说明符用于指定将变量值设置到哪个存储区域中，也就是说，当自动变量加上__block说明符之后，会改变这个自动变量的存储区域。
    //val：保存了最初的val变量，也就是说原来单纯的int类型的val变量被__block修饰后生成了一个结构体。这个结构体其中一个成员变量持有原来的val变量。
    //forwarding：通过forwarding，可以实现无论block变量配置在栈上还是堆上都能正确地访问block变量，也就是说__forwarding是指向自身的。
    
    //    怎么实现的？
    //    最初，block变量在栈上时，它的成员变量forwarding指向栈上的__block变量结构体实例。
    //    在block被复制到堆上时，会将forwarding的值替换为堆上的目标block变量用结构体实例的地址。而在堆上的目标block变量自己的__forwarding的值就指向它自己。
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test1();
        test2();
        test3();
        test4();
    }
    return 0;
}
