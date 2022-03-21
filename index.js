'use strict';

import React from 'react';
import {
	NativeModules,
	Platform,
} from 'react-native';
const _CarrierInfo = require('react-native').NativeModules.RNCarrierInfo;

export default class CarrierInfo {
	static async allowsVOIP() {
		if (Platform.OS === 'android') return true;
		return await _CarrierInfo.allowsVOIP();
	}

	static async carrierName() {
		return await _CarrierInfo.carrierName();
	}

	static async isoCountryCode() {
		return await _CarrierInfo.isoCountryCode();
	}

	static async mobileCountryCode() {
		return await _CarrierInfo.mobileCountryCode();
	}

	static async mobileNetworkCode() {
		return await _CarrierInfo.mobileNetworkCode();
	}

	static async mobileNetworkOperator() {
		return await _CarrierInfo.mobileNetworkOperator();
  	}

  	static async getIccid() {
		return await _CarrierInfo.getIccid();
	}

	static async getIccidList() {
		return await _CarrierInfo.getIccidList();
	}

 	static async simcardPresent() {
		return await _CarrierInfo.simcardPresent();
  	}
}
