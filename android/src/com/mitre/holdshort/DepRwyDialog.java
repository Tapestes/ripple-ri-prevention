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

import java.util.Timer;
import java.util.TimerTask;

import android.app.Dialog;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;


public class DepRwyDialog extends Dialog {

	private LinearLayout runwayHolder;
	private String depRunway;
	DepRwyDialog dialog;
	int loadNum = 0;
	int allFalse = 0;
	private String oldDepRunway;
	Boolean change = false;
	Boolean firstLoad = false;
	Boolean oldLoad = false;
	TextView dialogText;

	public DepRwyDialog(Context context) {
		super(context);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.dialog = this;

	}

	public Handler mainHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {

			loadNum = loadNum + 1;
			depRunway = null;

			runwayHolder = (LinearLayout) findViewById(R.id.runwayHolder);
			dialogText = (TextView) findViewById(R.id.depRwyDialogText);
			int children = runwayHolder.getChildCount();
			allFalse = 0;
			dialogText.setText("Set the assigned departure runway");

			for (int i = 0; i < children; i++) {

				DepRunwayBar child = (DepRunwayBar) runwayHolder.getChildAt(i);
				if (child.getRwyId() != Integer.valueOf(msg.what)) {
					child.setRunwayStatus(0);
					child.setThumbBounds(0);

				} else {

					if (child.getRunwayStatus() == 2) {

						depRunway = child.getRunwayLeftText();
						dialogText.setText("Departure runway set to " + depRunway);

						if (!oldLoad
								|| (oldLoad && !(depRunway.equalsIgnoreCase(oldDepRunway)) && loadNum > 1)) {

							Timer timer = new Timer();
							timer.schedule(new TimerTask() {

								public void run() {
									dialog.cancel();
								}
							}, 1500);

						}
					}
				}

				if (child.getRunwayStatus() == 1) {

					depRunway = child.getRunwayRightText();
					dialogText.setText("Departure runway set to " + depRunway);

					if (!oldLoad
							|| (oldLoad && !(depRunway.equalsIgnoreCase(oldDepRunway)) && loadNum > 1)) {

						Timer timer = new Timer();
						timer.schedule(new TimerTask() {

							public void run() {
								dialog.cancel();
							}
						}, 1500);

					}

				}

			}

		}

	};

	public String getDepRwy() {
		return this.depRunway;

	}

	public void setDepRwy(String depRwy) {
		this.depRunway = depRwy;

	}

	public void setOldLoad(Boolean bool) {
		this.oldLoad = bool;
	}

	public void setOldRunway(String oldRwy) {
		this.oldDepRunway = oldRwy;
	}

}
