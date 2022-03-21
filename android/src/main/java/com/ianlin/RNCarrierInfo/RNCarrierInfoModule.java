package com.ianlin.RNCarrierInfo;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.os.Build;
import java.util.List;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

public class RNCarrierInfoModule extends ReactContextBaseJavaModule {
    private final static String TAG = RNCarrierInfoModule.class.getCanonicalName();
    private final static String E_NO_CARRIER_NAME = "no_carrier_name";
    private final static String E_NO_ISO_COUNTRY_CODE = "no_iso_country_code";
    private final static String E_NO_MOBILE_COUNTRY_CODE = "no_mobile_country_code";
    private final static String E_NO_MOBILE_NETWORK = "no_mobile_network";
    private final static String E_NO_NETWORK_OPERATOR = "no_network_operator";
    private TelephonyManager mTelephonyManager;
    private SubscriptionManager mSubscriptionManager;

    public RNCarrierInfoModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mTelephonyManager = (TelephonyManager) reactContext.getSystemService(Context.TELEPHONY_SERVICE);
        mSubscriptionManager = (SubscriptionManager) reactContext.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
    }

    @Override
    public String getName() {
        return "RNCarrierInfo";
    }

    @ReactMethod
    public void carrierName(Promise promise) {
        String carrierName = mTelephonyManager.getSimOperatorName();
        mTelephonyManager.hasCarrierPrivileges();
        if (carrierName != null && !"".equals(carrierName)) {
            promise.resolve(carrierName);
        } else {
            promise.reject(E_NO_CARRIER_NAME, "No carrier name");
        }
    }

    @ReactMethod
    public void isoCountryCode(Promise promise) {
        String iso = mTelephonyManager.getSimCountryIso();
        if (iso != null && !"".equals(iso)) {
            promise.resolve(iso);
        } else {
            promise.reject(E_NO_ISO_COUNTRY_CODE, "No iso country code");
        }
    }

    // returns MCC (3 digits)
    @ReactMethod
    public void mobileCountryCode(Promise promise) {
        String plmn = mTelephonyManager.getSimOperator();
        if (plmn != null && !"".equals(plmn)) {
            promise.resolve(plmn.substring(0, 3));
        } else {
            promise.reject(E_NO_MOBILE_COUNTRY_CODE, "No mobile country code");
        }
    }

    // returns MNC (2 or 3 digits)
    @ReactMethod
    public void mobileNetworkCode(Promise promise) {
        String plmn = mTelephonyManager.getSimOperator();
        if (plmn != null && !"".equals(plmn)) {
            promise.resolve(plmn.substring(3));
        } else {
            promise.reject(E_NO_MOBILE_NETWORK, "No mobile network code");
        }
    }

    // return MCC + MNC (5 or 6 digits), e.g. 20601
    @ReactMethod
    public void mobileNetworkOperator(Promise promise) {
        String plmn = mTelephonyManager.getSimOperator();
        if (plmn != null && !"".equals(plmn)) {
            promise.resolve(plmn);
        } else {
            promise.reject(E_NO_NETWORK_OPERATOR, "No mobile network operator");
        }
    }

    @ReactMethod
    public void getIccid(Promise promise) {

      String iccid = null;
      final int sdkVersion = Build.VERSION.SDK_INT;
      if (sdkVersion >= 29) {
        // Custom ICCID generation similar to iOS plugin for android 10+ only
        List<SubscriptionInfo> sis = mSubscriptionManager.getActiveSubscriptionInfoList();
        String simInfo = "";

        if (sis != null && sis.size() > 0) {
        	// Getting first SubscriptionInfo
        	SubscriptionInfo si = sis.get(0);

        	CharSequence carrierName = si.getCarrierName();
        	String cName = "";
        	String mnc = si.getMncString();
        	String mcc = si.getMccString();

        	if (carrierName == null) {
          		carrierName = "";
        	} else {
          		cName = carrierName.toString();
          		cName = cName.length() > 14 ? cName.substring(0, 14) : cName;
        	}

        	if (mnc == null) {
          		mnc = "";
       		}

        	if (mcc == null) {
          		mcc = "";
        	}
	
        	simInfo = cName + mcc + mnc;
        }
        promise.resolve(simInfo);
      } else {
        // Used by Android 9 and below
        try {
          iccid = mTelephonyManager.getSimSerialNumber();
        } catch (Exception e) {
          e.printStackTrace();
        }
        promise.resolve(iccid);
      }
    }

    // testing method, returns Iccid:CarrierName:MNC:MCC:IsEmbedded for each SIM
    @ReactMethod
    public void getIccidList(Promise promise) {
      List<SubscriptionInfo> sis = mSubscriptionManager.getActiveSubscriptionInfoList();

      String siList = "";
      final int sdkVersion = Build.VERSION.SDK_INT;

      for (SubscriptionInfo si : sis) {
        String iccid = si.getIccId();
        String carrierName = si.getCarrierName().toString();

        String mnc = "";
        String mcc = "";
        if (sdkVersion < 29) {
          mnc = si.getMnc() != -1 ? Integer.toString(si.getMnc()) : "";
          mcc = si.getMcc() != -1 ? Integer.toString(si.getMcc()) : "";
        } else  {
          mnc = si.getMncString();
          mcc = si.getMccString();
        }

        boolean isEmbedded = si.isEmbedded();
        siList = siList + iccid + ":" + carrierName + ":" + mnc + ":"  + mcc + ":" + isEmbedded + "|";
      }
      promise.resolve(siList);
    }

	@ReactMethod
	  public void simcardPresent(Promise promise) {

		int simState = mTelephonyManager.getSimState();
		boolean simCardAvailability = true;

		switch (simState) {
		case TelephonyManager.SIM_STATE_ABSENT:
		  simCardAvailability = false;
		  break;
		}

		promise.resolve(simCardAvailability);

	  }
}



