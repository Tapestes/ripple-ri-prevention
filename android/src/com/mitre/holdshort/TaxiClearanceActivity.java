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
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;


public class TaxiClearanceActivity extends Activity {

	TextView runwayBtn;
	EditText taxiPath;
	String[] singleRunways;
	String[] doubleRunways;
	List<String> runwayList;
	ListView instListView;
	ArrayAdapter<String> instListAdapter;
	LinearLayout buttonGroup;
	ArrayList<String> instructionList;
	String depRunway = "UNK";
	String[] instructionArray;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.taxi_keyboard2);

		// Handle Change of Focus for EditText Fields
		runwayBtn = (TextView) findViewById(R.id.Runway);
		runwayBtn.setOnClickListener(runwayClickListener);
		runwayBtn.setText("Unknown");

		instructionList = new ArrayList<String>();
		runwayList = new ArrayList<String>();
		buttonGroup = (LinearLayout) findViewById(R.id.KeyBoard);

		instListView = (ListView) findViewById(R.id.instructionList);
		instListView.setTranscriptMode(ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
		instListAdapter = new TaxiInstructionAdapter(TaxiClearanceActivity.this,
				R.layout.row2, instructionList);
		instListView.setAdapter(instListAdapter);
		instListView.setOnItemLongClickListener(instLongClickListener);

		Bundle extras = getIntent().getExtras();

		if (extras != null) {

			if (extras.containsKey("com.mitre.holdshort.TAXI_RUNWAY")) {
				runwayBtn.setText("RWY "
						+ extras.getString("com.mitre.holdshort.TAXI_RUNWAY"));
				runwayBtn.setBackgroundResource(R.drawable.new_thumb);
				runwayBtn.setPadding(10, 10, 10, 10);

			} else {

				runwayBtn.setText("Not Set");

			}

			if (extras.containsKey("com.mitre.holdshort.TAXI_PATH")) {
				instructionArray = ((String[]) extras
						.getStringArray("com.mitre.holdshort.TAXI_PATH"));

				for (int i = 0; i < instructionArray.length; i++) {
					instructionList.add(instructionArray[i]);
					instListAdapter.notifyDataSetChanged();
				}
			}

			doubleRunways = ((String) extras
					.getString("com.mitre.holdshort.RUNWAYS")).split(",");
			singleRunways = ((String) extras
					.getString("com.mitre.holdshort.RUNWAYS")).split(",|-");
		}

		for (int i = 0; i < doubleRunways.length; i++) {
			String[] rwyParts = doubleRunways[i].split("-");
			runwayList.add(rwyParts[0]);
			runwayList.add(rwyParts[1]);
		}

		// Set up Special Button Events
		Button doneBtn = (Button) findViewById(R.id.btn_done);
		doneBtn.setOnClickListener(finishTaxiClearance);

		Button holdBtn = (Button) findViewById(R.id.btn_hold);
		holdBtn.setOnClickListener(holdButtonClick);

		Button backBtn = (Button) findViewById(R.id.btn_back);
		backBtn.setOnClickListener(bkspButtonClick);
		backBtn.setOnLongClickListener(clearListener);

		Button spaceBtn = (Button) findViewById(R.id.btn_space);
		spaceBtn.setOnClickListener(spaceButtonClick);

		Button crossBtn = (Button) findViewById(R.id.btn_cross);
		crossBtn.setOnClickListener(crossButtonClick);

		Button taxiBtn = (Button) findViewById(R.id.btn_taxi);
		taxiBtn.setOnClickListener(taxiButtonClick);

		Button positionBtn = (Button) findViewById(R.id.btn_position);
		positionBtn.setOnClickListener(positionButtonClick);

		Button btn_comma = (Button) findViewById(R.id.btn_comma);
		btn_comma.setOnClickListener(punctuationButtonClick);

		Button btn_period = (Button) findViewById(R.id.btn_period);
		btn_period.setOnClickListener(punctuationButtonClick);

		Button btn_cancel = (Button) findViewById(R.id.btn_cancel);
		btn_cancel.setOnClickListener(cancelButtonClick);

		// Set Up Number Buttons
		Button btn_1 = (Button) findViewById(R.id.btn_1);
		btn_1.setOnClickListener(standardButtonClick);
		Button btn_2 = (Button) findViewById(R.id.btn_2);
		btn_2.setOnClickListener(standardButtonClick);
		Button btn_3 = (Button) findViewById(R.id.btn_3);
		btn_3.setOnClickListener(standardButtonClick);
		Button btn_4 = (Button) findViewById(R.id.btn_4);
		btn_4.setOnClickListener(standardButtonClick);
		Button btn_5 = (Button) findViewById(R.id.btn_5);
		btn_5.setOnClickListener(standardButtonClick);
		Button btn_6 = (Button) findViewById(R.id.btn_6);
		btn_6.setOnClickListener(standardButtonClick);
		Button btn_7 = (Button) findViewById(R.id.btn_7);
		btn_7.setOnClickListener(standardButtonClick);
		Button btn_8 = (Button) findViewById(R.id.btn_8);
		btn_8.setOnClickListener(standardButtonClick);
		Button btn_9 = (Button) findViewById(R.id.btn_9);
		btn_9.setOnClickListener(standardButtonClick);
		Button btn_0 = (Button) findViewById(R.id.btn_0);
		btn_0.setOnClickListener(standardButtonClick);

		// Set Up Letter Buttons
		Button btn_q = (Button) findViewById(R.id.btn_q);
		btn_q.setOnClickListener(standardButtonClick);
		Button btn_w = (Button) findViewById(R.id.btn_w);
		btn_w.setOnClickListener(standardButtonClick);
		Button btn_e = (Button) findViewById(R.id.btn_e);
		btn_e.setOnClickListener(standardButtonClick);
		Button btn_r = (Button) findViewById(R.id.btn_r);
		btn_r.setOnClickListener(standardButtonClick);
		Button btn_t = (Button) findViewById(R.id.btn_t);
		btn_t.setOnClickListener(standardButtonClick);
		Button btn_y = (Button) findViewById(R.id.btn_y);
		btn_y.setOnClickListener(standardButtonClick);
		Button btn_u = (Button) findViewById(R.id.btn_u);
		btn_u.setOnClickListener(standardButtonClick);
		Button btn_i = (Button) findViewById(R.id.btn_i);
		btn_i.setOnClickListener(standardButtonClick);
		Button btn_o = (Button) findViewById(R.id.btn_o);
		btn_o.setOnClickListener(standardButtonClick);
		Button btn_p = (Button) findViewById(R.id.btn_p);
		btn_p.setOnClickListener(standardButtonClick);

		Button btn_a = (Button) findViewById(R.id.btn_a);
		btn_a.setOnClickListener(standardButtonClick);
		Button btn_s = (Button) findViewById(R.id.btn_s);
		btn_s.setOnClickListener(standardButtonClick);
		Button btn_d = (Button) findViewById(R.id.btn_d);
		btn_d.setOnClickListener(standardButtonClick);
		Button btn_f = (Button) findViewById(R.id.btn_f);
		btn_f.setOnClickListener(standardButtonClick);
		Button btn_g = (Button) findViewById(R.id.btn_g);
		btn_g.setOnClickListener(standardButtonClick);
		Button btn_h = (Button) findViewById(R.id.btn_h);
		btn_h.setOnClickListener(standardButtonClick);
		Button btn_j = (Button) findViewById(R.id.btn_j);
		btn_j.setOnClickListener(standardButtonClick);
		Button btn_k = (Button) findViewById(R.id.btn_k);
		btn_k.setOnClickListener(standardButtonClick);
		Button btn_l = (Button) findViewById(R.id.btn_l);
		btn_l.setOnClickListener(standardButtonClick);

		Button btn_z = (Button) findViewById(R.id.btn_z);
		btn_z.setOnClickListener(standardButtonClick);
		Button btn_x = (Button) findViewById(R.id.btn_x);
		btn_x.setOnClickListener(standardButtonClick);
		Button btn_c = (Button) findViewById(R.id.btn_c);
		btn_c.setOnClickListener(standardButtonClick);
		Button btn_v = (Button) findViewById(R.id.btn_v);
		btn_v.setOnClickListener(standardButtonClick);
		Button btn_b = (Button) findViewById(R.id.btn_b);
		btn_b.setOnClickListener(standardButtonClick);
		Button btn_n = (Button) findViewById(R.id.btn_n);
		btn_n.setOnClickListener(standardButtonClick);
		Button btn_m = (Button) findViewById(R.id.btn_m);
		btn_m.setOnClickListener(standardButtonClick);

	}

	private OnItemLongClickListener instLongClickListener = new OnItemLongClickListener() {

		DialogNoTitle dialog;
		long itemID = 0;

		@Override
		public boolean onItemLongClick(AdapterView<?> arg0, View arg1,
				int arg2, long arg3) {

			String[] options = new String[] { "Delete Instruction",
					"Clear Entire List" };

			itemID = arg3;
			dialog = new DialogNoTitle(TaxiClearanceActivity.this);
			dialog.setContentView(R.layout.options_dialog);
			ListView optionsList = (ListView) dialog
					.findViewById(R.id.optionsListView);
			optionsList.setAdapter(new ArrayAdapter<String>(
					TaxiClearanceActivity.this, android.R.layout.simple_list_item_1,
					options));
			optionsList.setOnItemClickListener(this.itemListener);
			dialog.show();
			return false;
		}

		private OnItemClickListener itemListener = new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				if (id == 0) {
					instructionList.remove((int) itemID);
					instListAdapter.notifyDataSetChanged();
					dialog.cancel();
				}

				if (id == 1) {
					instructionList.clear();
					instListAdapter.notifyDataSetChanged();
					dialog.cancel();
				}
			}
		};

	};
	private OnClickListener runwayClickListener = new OnClickListener() {

		TaxiDepDialog dialog;

		@Override
		public void onClick(View v) {
			dialog = new TaxiDepDialog(TaxiClearanceActivity.this);

			dialog.setContentView(R.layout.taxi_deprwy_dialog);
			WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();

			lp.gravity = Gravity.TOP | Gravity.LEFT;
			lp.y = runwayBtn.getBottom() + 40;
			lp.x = runwayBtn.getLeft() - 10;
			lp.dimAmount = 0.0f;
			// lp.height=height-lp.y-20;

			java.util.Arrays.sort(singleRunways);
			dialog.getWindow().setAttributes(lp);
			dialog.getWindow().addFlags(
					WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
			GridView list = (GridView) dialog.findViewById(R.id.listView);

			list.setAdapter(new ArrayAdapter<String>(TaxiClearanceActivity.this,
					R.layout.row, R.id.rowText, singleRunways));
			list.setOnItemClickListener(this.itemListener);

			dialog.show();
		}

		private OnItemClickListener itemListener = new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				depRunway = (String) ((TextView) view
						.findViewById(R.id.rowText)).getText();
				runwayBtn.setText("RWY " + depRunway);
				runwayBtn.setBackgroundResource(R.drawable.new_thumb);
				runwayBtn.setPadding(10, 10, 10, 10);
				dialog.cancel();
			}
		};
	};

	private OnClickListener finishTaxiClearance = new OnClickListener() {

		@Override
		public void onClick(View v) {

			Intent clearance = new Intent();

			if (depRunway != "UNK") {
				clearance
						.putExtra("com.mitre.holdshort.TAXI_RUNWAY", depRunway);
			}

			if (instructionList.size() > 0) {

				String[] instructionArray = (String[]) instructionList
						.toArray(new String[instructionList.size()]);

				clearance.putExtra("com.mitre.holdshort.TAXI_PATH",
						instructionArray);
			}

			setResult(RESULT_OK, clearance);
			finish();

		}
	};

	private OnClickListener cancelButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {
			setResult(RESULT_CANCELED);
			finish();
		}
	};

	private OnLongClickListener clearListener = new OnLongClickListener() {

		@Override
		public boolean onLongClick(View v) {

			return true;
		}

	};

	private OnClickListener standardButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Button btn = (Button) v;
			if (instructionList.size() > 0) {
				instructionList.set(instListAdapter.getCount() - 1,
						instructionList.get(instListAdapter.getCount() - 1)
								+ btn.getText());
				instListAdapter.notifyDataSetChanged();
			}
		}
	};

	private OnClickListener punctuationButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Button btn = (Button) v;
			if (instructionList.size() > 0) {
				instructionList.set(instListAdapter.getCount() - 1,
						instructionList.get(instListAdapter.getCount() - 1)
								+ btn.getText());
				instListAdapter.notifyDataSetChanged();
			}
		}
	};

	private OnClickListener bkspButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {

			if (instructionList.size() > 0) {
				String itemText = instructionList.get(instListAdapter
						.getCount() - 1);
				instructionList
						.set(instListAdapter.getCount() - 1,
								(String) itemText.subSequence(0,
										itemText.length() - 1));
				instListAdapter.notifyDataSetChanged();

			}
		}
	};

	private OnClickListener holdButtonClick = new OnClickListener() {

		TaxiDepDialog dialog;

		@Override
		public void onClick(View v) {

			dialog = new TaxiDepDialog(TaxiClearanceActivity.this);

			dialog.setContentView(R.layout.taxi_doublerwy_dialog);
			WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
			TextView dialogText = (TextView) dialog
					.findViewById(R.id.dialogText);
			dialogText.setText("Hold Short of:");
			lp.gravity = Gravity.TOP | Gravity.CENTER;
			lp.y = buttonGroup.getTop() + 70;
			lp.dimAmount = 0.0f;

			java.util.Arrays.sort(doubleRunways);
			dialog.getWindow().setAttributes(lp);
			dialog.getWindow().addFlags(
					WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
			GridView list = (GridView) dialog.findViewById(R.id.listView);

			list.setAdapter(new ArrayAdapter<String>(TaxiClearanceActivity.this,
					R.layout.row, R.id.rowText, doubleRunways));
			list.setOnItemClickListener(this.itemListener);

			dialog.show();

		}

		private OnItemClickListener itemListener = new OnItemClickListener() {

			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				addItemToList("Hold Short of RWY "
						+ ((TextView) view.findViewById(R.id.rowText))
								.getText());
				dialog.cancel();
			}
		};
	};

	private OnClickListener crossButtonClick = new OnClickListener() {
		TaxiDepDialog dialog;

		@Override
		public void onClick(View v) {

			dialog = new TaxiDepDialog(TaxiClearanceActivity.this);

			dialog.setContentView(R.layout.taxi_doublerwy_dialog);
			WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
			TextView dialogText = (TextView) dialog
					.findViewById(R.id.dialogText);
			dialogText.setText("Cross:");
			lp.gravity = Gravity.TOP | Gravity.CENTER;
			lp.y = buttonGroup.getTop() + 70;
			lp.dimAmount = 0.0f;

			java.util.Arrays.sort(doubleRunways);
			dialog.getWindow().setAttributes(lp);
			dialog.getWindow().addFlags(
					WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
			GridView list = (GridView) dialog.findViewById(R.id.listView);

			list.setAdapter(new ArrayAdapter<String>(TaxiClearanceActivity.this,
					R.layout.row, R.id.rowText, doubleRunways));
			list.setOnItemClickListener(this.itemListener);

			dialog.show();

		}

		private OnItemClickListener itemListener = new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				addItemToList("Cross RWY "
						+ ((TextView) view.findViewById(R.id.rowText))
								.getText());
				dialog.cancel();
			}
		};

	};

	private OnClickListener positionButtonClick = new OnClickListener() {
		TaxiDepDialog dialog;

		@Override
		public void onClick(View v) {

			dialog = new TaxiDepDialog(TaxiClearanceActivity.this);

			dialog.setContentView(R.layout.taxi_doublerwy_dialog);
			WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
			TextView dialogText = (TextView) dialog
					.findViewById(R.id.dialogText);
			dialogText.setText("Line Up and Wait on:");
			lp.gravity = Gravity.TOP | Gravity.CENTER;
			lp.y = buttonGroup.getTop() + 70;
			lp.dimAmount = 0.0f;

			java.util.Arrays.sort(doubleRunways);
			dialog.getWindow().setAttributes(lp);
			dialog.getWindow().addFlags(
					WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
			GridView list = (GridView) dialog.findViewById(R.id.listView);

			list.setAdapter(new ArrayAdapter<String>(TaxiClearanceActivity.this,
					R.layout.row, R.id.rowText, doubleRunways));
			list.setOnItemClickListener(this.itemListener);

			dialog.show();

		}

		private OnItemClickListener itemListener = new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {

				addItemToList("Line Up and Wait - RWY "
						+ ((TextView) view.findViewById(R.id.rowText))
								.getText());
				dialog.cancel();
			}
		};
	};

	private OnClickListener taxiButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {

			addItemToList("Taxi via");
		}
	};

	private OnClickListener spaceButtonClick = new OnClickListener() {

		@Override
		public void onClick(View v) {

			if (instructionList.size() > 0) {
				String itemText = instructionList.get(instListAdapter
						.getCount() - 1);
				instructionList.set(instListAdapter.getCount() - 1, itemText
						+ " ");
				instListAdapter.notifyDataSetChanged();
			}
		}
	};

	private void addItemToList(String text) {

		instructionList.add(text + " ");
		instListAdapter.notifyDataSetChanged();

	}

}
