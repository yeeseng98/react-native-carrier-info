//
//  RNCarrierInfo.m
//  RNCarrierInfo
//
//  Created by Matthew Knight on 09/05/2015.
//  Copyright (c) 2015 Anarchic Knight. All rights reserved.
//

#import "RNCarrierInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation RNCarrierInfo

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(allowsVOIP:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    BOOL allowsVoip = [[nInfo subscriberCellularProvider] allowsVOIP];
    resolve([NSNumber numberWithBool:allowsVoip]);
}

RCT_EXPORT_METHOD(carrierName:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *carrierName = [[nInfo subscriberCellularProvider] carrierName];
    if(carrierName)
    {
        resolve(carrierName);
    }
    else
    {
        reject(@"no_carrier_name", @"Carrier Name cannot be resolved", nil);
    }
}

RCT_EXPORT_METHOD(isoCountryCode:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *iso = [[nInfo subscriberCellularProvider] isoCountryCode];
    if(iso)
    {
        resolve(iso);
    }
    else
    {
        reject(@"no_iso_country_code", @"ISO country code cannot be resolved", nil);
    }
}

RCT_EXPORT_METHOD(mobileCountryCode:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *mcc = [[nInfo subscriberCellularProvider] mobileCountryCode];
    if(mcc)
    {
        resolve(mcc);
    }
    else
    {
        reject(@"no_mobile_country_code", @"Mobile country code cannot be resolved", nil);
    }
}

RCT_EXPORT_METHOD(mobileNetworkCode:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *mnc = [[nInfo subscriberCellularProvider] mobileNetworkCode];
    if(mnc)
    {
        resolve(mnc);
    }
    else
    {
        reject(@"no_mobile_network", @"Mobile network code cannot be resolved", nil);
    }
}

// return MCC + MNC, e.g. 46697
RCT_EXPORT_METHOD(mobileNetworkOperator:(RCTPromiseResolveBlock)resolve
                               rejecter:(RCTPromiseRejectBlock)reject)
{
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *mcc = [[nInfo subscriberCellularProvider] mobileCountryCode];
    NSString *mnc = [[nInfo subscriberCellularProvider] mobileNetworkCode];
    NSString *operator = [NSString stringWithFormat: @"%@%@", mcc, mnc];

    if ([(NSString *)mcc length] == 0 && [(NSString *)mnc length] == 0) {
         reject(@"no_network_operator", @"Mobile network operator code cannot be resolved", nil);
    }else{
        resolve(operator);

    }
}

// return custom UID
RCT_EXPORT_METHOD(getIccid:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (@available(iOS 12.0, *)) {
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];

    // serviceSubscriberCellularProviders dictionary does not have defined order,
    // hence no guarantee that same info is returned from different app executions.
    NSDictionary<NSString *, CTCarrier *> *dicCarrier =  [nInfo serviceSubscriberCellularProviders];
    NSString* result = @"";

    for (id key in dicCarrier) {
      NSString* carrierName = [[dicCarrier objectForKey:key] carrierName];
      NSString* countryCode = [[dicCarrier objectForKey:key] mobileCountryCode];
      NSString* networkCode = [[dicCarrier objectForKey:key] mobileNetworkCode];

      if (!carrierName) {
        carrierName = @"";
      } else {
        carrierName = ([carrierName length] > 14) ? [carrierName substringToIndex:14] : carrierName;
      }

      if (!countryCode) {
        countryCode = @"";
      }

      if (!networkCode) {
        networkCode = @"";
      }

      result = [[carrierName stringByAppendingString:countryCode] stringByAppendingString:networkCode];

      // return first non-empty result found in dictionary
      if ([(NSString *)countryCode length] > 0 && [(NSString *)networkCode length] > 0) {
          resolve(result);
          return;
      }
    }

    // resolve empty string if nothing found
    resolve(result);
  } else {
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* carrier = [nInfo subscriberCellularProvider];

    NSString* carrierName = [carrier carrierName];
    NSString* countryCode = [carrier mobileCountryCode];
    NSString* networkCode = [carrier mobileNetworkCode];

    if (!carrierName) {
    carrierName = @"";
    }

    if (!countryCode) {
    countryCode = @"";
    }

    if (!networkCode) {
    networkCode = @"";
    }

    NSString* result = [[carrierName stringByAppendingString:countryCode] stringByAppendingString:networkCode];

    resolve(result);
  }
}

// iOS 12+ only
// returns string of custom UID(s) with pipe delimiter.
RCT_EXPORT_METHOD(getIccidList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString* simResult = @"";
  if (@available(iOS 12.0, *)) {
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSDictionary<NSString *, CTCarrier *> *dicCarrier =  [nInfo serviceSubscriberCellularProviders];

    for (id key in dicCarrier) {
      NSString* carrierName = [[dicCarrier objectForKey:key] carrierName];
      NSString* countryCode = [[dicCarrier objectForKey:key] mobileCountryCode];
      NSString* networkCode = [[dicCarrier objectForKey:key] mobileNetworkCode];

      if (!carrierName) {
        carrierName = @"";
      } else {
        carrierName = ([carrierName length] > 14) ? [carrierName substringToIndex:14] : carrierName;
      }

      if (!countryCode) {
        countryCode = @"";
      }

      if (!networkCode) {
        networkCode = @"";
      }

      NSString* result = [[carrierName stringByAppendingString:countryCode] stringByAppendingString:networkCode];
      simResult = [[simResult stringByAppendingString:result] stringByAppendingString:@"|"];
    }
  }
  resolve(simResult);
}

// check simcard availability
RCT_EXPORT_METHOD(simcardPresent:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  BOOL simcardAvailable = false;

  if (@available(iOS 12.0, *)) {
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSDictionary<NSString *, CTCarrier *> *dicCarrier =  [nInfo serviceSubscriberCellularProviders];

    for (id key in dicCarrier) {
      NSString* mcc = [[dicCarrier objectForKey:key] mobileCountryCode];
      NSString* mnc = [[dicCarrier objectForKey:key] mobileNetworkCode];

      if ([(NSString *)mcc length] > 0 && [(NSString *)mnc length] > 0) {
        simcardAvailable = true;
        resolve([NSNumber numberWithBool:simcardAvailable]);
        return;
      }
    }
    resolve([NSNumber numberWithBool:simcardAvailable]);
  } else {
    CTTelephonyNetworkInfo *nInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *mcc = [[nInfo subscriberCellularProvider] mobileCountryCode];
    NSString *mnc = [[nInfo subscriberCellularProvider] mobileNetworkCode];

    if ([(NSString *)mcc length] == 0 && [(NSString *)mnc length] == 0) {
      resolve([NSNumber numberWithBool:simcardAvailable]);
    }else{
      simcardAvailable = true;
      resolve([NSNumber numberWithBool:simcardAvailable]);
    }
  }
}

@end



