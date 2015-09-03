//
//  ViewController.m
//  33.5-post&get 实现登录
//
//  Created by Mac on 14-10-22.
//  Copyright (c) 2014年 MN. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *Account;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@property (weak, nonatomic) IBOutlet UILabel *display;
- (IBAction)login:(id)sender;
@end

@implementation ViewController




            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

   /**
     所有网络请求都是异步请求的，都是在飞主线程之外的线程上进行 异步串行
    原因：因为网络请求是需要耗时间的，网络请求没有完成不能执行下面的步骤；
         但是网络请求不能占用主线程，这样用户才可以在主线程上干点别的事情，结论就是登录就是异步串行的
    */


#pragma mark post to login

-(void)postLogin{
  
    NSString *str = [NSString stringWithFormat: @"http://localhost/login.php"];
    
    
    // 1.Create  a  url ;
    NSURL *url = [NSURL URLWithString:str];
    // 2.change url become to mutable request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 3.set method of request
    request.HTTPMethod = @"POST";
    // 4.set httpbody of request
    
    NSString *body = [NSString stringWithFormat:@"username=%@&password=%@",self.Account.text,self.pwd.text];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    // 5.NSURLConnection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    //  6.判断结果是否收到
    //   这就是登录之后要实现的后续工作
         if(connectionError == nil){
             NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             NSLog(@"%@-----%@",result,[NSThread currentThread]);
             
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 self.display.text = result;
                }];
           
         }else{
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  self.display.text = @"Login failed!";
              }];
              NSLog(@"Login failed!");
         }
      }];
 }



-(void)getLogin{

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/login.php?username=%@&password=%@", self.
                         Account.text, self.pwd.text];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. Connection
    // 1> 登录完成之前,不能做后续工作!
    // 2> 登录进行中,可以允许用户干点别的会更好!
    // 3> 让登录操作在其他线程中进行,就不会阻塞主线程的工作
    // 4> 结论:登陆也是异步访问,中间需要阻塞住
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError == nil) {
            // 网络请求结束之后执行!
            // 将Data转换成字符串
           NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
           
            Model *model = [[Model alloc ] init];
#warning 此处kvc  属性名称没有具体对准，因为没有不会写 php， 登录不了，测试不了
            
            [model setValuesForKeysWithDictionary:dict];
            
            // num = 2
            NSLog(@"%@ %@", str, [NSThread currentThread]);
            
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.display.text = @"登录完成";
            }];
        }
    }];
    
    // num = 1
    NSLog(@"come here %@", [NSThread currentThread]);
    
    NSURLResponse *response = nil;
    // 1. &response真的理解了吗?
    // 2. error:为什么是NULL,而不是nil
    // NULL是C语言的 = 0
    // 在C语言中,如果将指针的地址指向0就不会有危险
    
    // nil是OC的,是一个空对象发送消息不会出问题
    //    [response MIMEType];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];

}
- (IBAction)login:(id)sender {
    
    [self getLogin];
    
}
@end
