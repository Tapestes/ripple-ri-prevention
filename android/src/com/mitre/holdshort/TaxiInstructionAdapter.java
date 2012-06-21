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

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;


public class TaxiInstructionAdapter extends ArrayAdapter<String> {

	
	private ArrayList<String> listOfInstructions;
	private Context context;
	private int textViewId;

	public TaxiInstructionAdapter(Context context, int textViewResourceId,
			ArrayList<String> items) {
		super(context, textViewResourceId, items);
		this.listOfInstructions = items;
		this.context = context;
		this.textViewId = textViewResourceId;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		TextView v = (TextView) convertView;
		if (v == null) {
			LayoutInflater vi = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			v = (TextView) vi.inflate(this.textViewId, null);
		}

		String instText = listOfInstructions.get(position);
		if (instText != null) {

			TextView tt = (TextView) v.findViewById(R.id.rowText);
			tt.setText(position+1 + ": " + instText);

		}
		return v;
	}
}
