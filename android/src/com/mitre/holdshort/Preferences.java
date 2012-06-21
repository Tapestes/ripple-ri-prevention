/*******************************************************************************
 * This is the copyright work of The MITRE Corporation, and was produced for the 
 * U. S. Government under Contract Number DTFAWA-10-C-00080, as well as subject 
 * to the Apache Licence, Version 2.0 dated January 2004. 
 * 
 * For further information, please contact The MITRE Corporation, Contracts Office, 
 * 7515 Colshire Drive, McLean, VA  22102-7539, (703) 983-6000.
 * 
 * Copyright 2011 The MITRE Corporation
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * 
 * You may obtain a copy of the License at
 * 
 * 	    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package com.mitre.holdshort;

import android.app.Dialog;
import android.content.SharedPreferences;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.preference.Preference.OnPreferenceClickListener;
import android.view.ViewGroup;
import android.widget.TextView;


public class Preferences extends PreferenceActivity implements
		OnSharedPreferenceChangeListener {
	private static final String PREFS_NAME = "com.mitre.org.holdshort.HoldShortPrefs";
	CheckBoxPreference aural;
	
	SharedPreferences settings;
	private Preference legalInfo;
	private CheckBoxPreference announceRwy;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		PreferenceManager pm = getPreferenceManager();
		pm.setSharedPreferencesName(PREFS_NAME);
	
		settings = getSharedPreferences(PREFS_NAME, 0);
		addPreferencesFromResource(R.xml.preferences);
		aural = (CheckBoxPreference) findPreference("auralAlerts");
		aural.setChecked(settings.getBoolean("auralAlerts", true));
		announceRwy = (CheckBoxPreference) findPreference("announceRWY");
		announceRwy.setChecked(settings.getBoolean("announceRWY", true));		
				
		legalInfo = (Preference) findPreference("legalInfo");
		legalInfo.setOnPreferenceClickListener(showLegalInfo);
		
	}
	
	private OnPreferenceClickListener showLegalInfo = new OnPreferenceClickListener(){

		@Override
		public boolean onPreferenceClick(Preference preference) {
			final Dialog dialog = new Dialog(Preferences.this);

			dialog.setContentView(R.layout.legal_stuff_dialog);
			dialog.setTitle("RIPPLE - Legal/Copyright Info");
			dialog.getWindow().setLayout(ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.FILL_PARENT);

			TextView consent = (TextView) dialog.findViewById(R.id.disclaimerAccept);
			TextView reject = (TextView) dialog.findViewById(R.id.disclaimerReject);

			consent.setVisibility(TextView.GONE);
			reject.setVisibility(TextView.GONE);
			dialog.show();
			return false;
		}
		
	};


	@Override
	public void onSharedPreferenceChanged(SharedPreferences sharedPreferences,
			String key) {
		// TODO Auto-generated method stub
		
	}

}
