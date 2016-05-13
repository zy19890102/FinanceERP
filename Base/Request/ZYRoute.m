//
//  ZYRoute.m
//  FinanceERP
//
//  Created by zhangyu on 16/4/25.
//  Copyright © 2016年 张昱. All rights reserved.
//

#import "ZYRoute.h"

#define NET_ERROR [NSError errorWithDomain:@"请检查网络连接" code:404 userInfo:nil]
#define ERROR(value) [NSError errorWithDomain:ERROR_INFO(value) code:500 userInfo:ERROR_CODE(value)]

#define ERROR_(error) [NSError errorWithDomain:error code:0 userInfo:nil]

#define REQUEST_SUCCESS(value) [[value objectForKey:@"success"] boolValue]

#define ERROR_INFO(value) [value objectForKey:@"msg"]==nil?@"未知错误":[value objectForKey:@"msg"]
#define ERROR_CODE(value) [value objectForKey:@"error_code"]==nil?@{}:@{@"code":[value objectForKey:@"error_code"]}

#define CHECK_LOGIN if(![ZYTools checkLogin])\
{\
    [subscriber sendError:ERROR_(@"您尚未登陆，请先登录后操作")];\
    [subscriber sendCompleted];\
    return nil;\
}\


@implementation ZYRoute
+ (instancetype)route
{
    static ZYRoute *route = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        route = [[ZYRoute alloc] init];
    });
    return route;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (RACSignal*)loginWith:(ZYLoginRequest*)myRequest
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                ZYUser *userInfo = [ZYUser mj_objectWithKeyValues:request.responseJSONObject[@"user_info"]];
                userInfo.loginState = ZYUserLoginSuccess;
                [subscriber sendNext:userInfo];
                [subscriber sendCompleted];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];
        return nil;
    }];
    return [signal map:^id(ZYUser *userInfo) {
        ZYUser *user = [ZYUser user];
        user.user_name = userInfo.user_name;
        user.phone = userInfo.phone;
        user.org_id = userInfo.org_id;
        user.roles = userInfo.roles;
        user.photo_url = userInfo.photo_url;
        user.job_title = userInfo.job_title;
        user.real_name = userInfo.real_name;
        user.member_id = userInfo.member_id;
        user.user_name = userInfo.user_name;
        user.org_name = userInfo.org_name;
        user.maill = userInfo.maill;
        user.pid = userInfo.pid;
        user.loginState = userInfo.loginState;
        return user;
    }];
}
- (id)loginCacheWith:(ZYLoginRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        ZYUser *userInfo = [ZYUser mj_objectWithKeyValues:myRequest.cacheJson[@"user_info"]];
        userInfo.loginState = ZYUserLogout;
        ZYUser *user = [ZYUser user];
        user.user_name = userInfo.user_name;
        user.phone = userInfo.phone;
        user.org_id = userInfo.org_id;
        user.roles = userInfo.roles;
        user.photo_url = userInfo.photo_url;
        user.job_title = userInfo.job_title;
        user.real_name = userInfo.real_name;
        user.member_id = userInfo.member_id;
        user.user_name = userInfo.user_name;
        user.org_name = userInfo.org_name;
        user.maill = userInfo.maill;
        user.pid = userInfo.pid;
        user.loginState = userInfo.loginState;
        return user;
    }
    return nil;
}
- (RACSignal*)bannersWith:(ZYBannerRequest*)myRequest
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
            else
            {
                
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYBannerItem mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }];
}
- (id)bannersCacheWith:(ZYBannerRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYBannerItem mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)checkInWith:(ZYCheckInRequest*)myRequest
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CHECK_LOGIN///检查登陆
        [myRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                ZYCheckInModel *model = [ZYCheckInModel mj_objectWithKeyValues:value];
                model.to_day_is_sign = YES;//签到成功
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            }
            else
            {
                
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        return nil;
    }];
    return [signal map:^id(id value) {
        return value;
    }];
}
- (RACSignal*)checkInDaysWith:(ZYCheckInDaysRequest*)myRequest
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
            else
            {
                
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYCheckInModel mj_objectWithKeyValues:value];
    }];
}
- (RACSignal*)warningEventList:(ZYWarningEventRquest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYWarningEvent mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }];
}
- (id)warningEventListCacheWith:(ZYWarningEventRquest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYWarningEvent mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)productList:(ZYProductRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYProductModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }];
}
- (id)productListCacheWith:(ZYProductRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYProductModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)businessProcessList:(ZYBusinessProcessRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
       
        return nil;
    }];
    return [signal map:^id(id value) {
        NSArray *arr = [ZYBusinessProcessModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
        for(ZYBusinessProcessModel *model in arr)
        {
            model.keyword = myRequest.project_name;//纪录关键字
        }
        return arr;
    }];
}
- (id)businessProcessListCacheWith:(ZYBusinessProcessRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYBusinessProcessModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)businessProcessStateCount:(ZYBussinessStateCountRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        return nil;
    }];
    return [signal map:^id(id value) {
        NSArray *arr = value[@"result_list"];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:arr.count];
        for(NSDictionary *dict in arr)
        {
            if(dict[@"count"]!=nil&&dict[@"dynamic_name"]!=nil)
            {
                [result setObject:dict[@"count"] forKey:dict[@"dynamic_name"]];
            }
        }
        return result;
    }];
}
- (RACSignal*)foreclosureHouseInfo:(ZYForeclosureHouseRequest*)myRequest
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
            else
            {
                
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYForeclosureHouseModel mj_objectWithKeyValues:value];
    }];
}

- (RACSignal*)banks:(ZYBanksRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYBankModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }];
}
- (id)banksCacheWith:(ZYBanksRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYBankModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)myCustomers:(ZYMyCustomerRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYCustomerModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }];
}
- (id)myCustomersCacheWith:(ZYMyCustomerRequest*)myRequest
{
    if(myRequest.cacheJson)
    {
        id value = myRequest.cacheJson;///使用缓存
        return [ZYCustomerModel mj_objectArrayWithKeyValuesArray:value[@"result_list"]];
    }
    return nil;
}
- (RACSignal*)businessProcessStateList:(ZYBusinessProcessingStateRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        
        return nil;
    }];
    return [signal map:^id(id value) {
        return [ZYBusinessProcessingStateModel mj_objectWithKeyValues:value];;
    }];
}
- (RACSignal*)businessProcessStateEdit:(ZYBussinessProcessingStateEditRequest*)myRequest
{
    @weakify(myRequest)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        CHECK_LOGIN///检查登陆
        
        [myRequest setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
            id value = request.responseJSONObject;
            if(REQUEST_SUCCESS(value))
            {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
                @strongify(myRequest)
                [myRequest saveJsonResponseToCacheFile:value];
            }
            else
            {
                [subscriber sendError:ERROR(value)];
            }
        } failure:^(__kindof YTKBaseRequest *request) {
            [subscriber sendError:NET_ERROR];
        }];
        [myRequest startWithoutCache];//强制刷新
        
        return nil;
    }];
    return [signal map:^id(id value) {
        return ERROR(value).domain;
    }];
}
@end
