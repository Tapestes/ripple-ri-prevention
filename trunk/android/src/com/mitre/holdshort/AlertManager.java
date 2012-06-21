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

public class AlertManager {

	/*
	 * This class handles all the alerts that are found
	 * by the logic and arbitrates based on a set of 
	 * heuristics we came to. The arbitration happens
	 * in the getAlertToShow() method.
	 * 
	 * currentAlerts is a list holding all of the alerts
	 * found during each pass of the logic (main.checkForAlert())
	 * 
	 */
	
	
	private List<Alert> currentAlerts;
	private RunwayManager rwyMgr;
	private boolean positionAndHold;

	public AlertManager(RunwayManager rwyMgr) {

		this.rwyMgr = rwyMgr;
		currentAlerts = new ArrayList<Alert>();

	}

	public void addAlert(Alert alert) {
		
		currentAlerts.add(alert);
	}

	public Alert getAlertToShow() {

		// Clear runway alerts from runway object

		for (RunwayZone rwy : rwyMgr.runways) {
			//Log.d(MainActivity.LOG_TAG, "Clearing runway alerts");
			rwy.setAlert(null);
		}

		if (positionAndHold) {
			//Log.d(MainActivity.LOG_TAG, "Returning Alert: Null - In position and hold");
			return null;
		}

		if (currentAlerts.size() == 0) {
			//Log.d(MainActivity.LOG_TAG, "Returning Alert: Null - No alerts in stack");
			return null;

		} else {
			
			//If any runways tested true for wrong runway takeoff, then issue crossing
			for (int i = 0; i < currentAlerts.size(); i++) {
				
				if (currentAlerts.get(i).getAlertType() == Alert.AlertType.WRONG_RUNWAY
						&& currentAlerts.get(i).isInside()) {

					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
						}
					}
					
					//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());
					return currentAlerts.get(i);
				}
			}
			
			//If any runways tested true for hold short + outside, then issue hold short alert
			for (int i = 0; i < currentAlerts.size(); i++) {

				if (currentAlerts.get(i).getAlertType() == Alert.AlertType.HOLD_SHORT
						&& !(currentAlerts.get(i).isInside())) {

					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
							//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());							
							return currentAlerts.get(i);
						}
					}
					
				}else if(currentAlerts.get(i).getAlertType() == Alert.AlertType.HOLD_SHORT
						&& currentAlerts.get(i).isInside() && currentAlerts.get(i).isPersistent()){
					
					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
							//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());							
							return currentAlerts.get(i);
						}
					}
				
				
				}
			}

			
			//If any runways tested true for outside + crossing, then issue no alerts 
			for (int i = 0; i < currentAlerts.size(); i++) {

				if (currentAlerts.get(i).getAlertType() == Alert.AlertType.CROSSING
						&& !(currentAlerts.get(i).isInside())) {

					// clear all alerts
					//Log.d(MainActivity.LOG_TAG, "Returning Alert: NULL - Outside - Crossing");					
					return null;
				}
			}

			
			
			//If any runways tested true for hold short no clearance + outside, then issue hold short no clearance alert			
			for (int i = 0; i < currentAlerts.size(); i++) {

				if (currentAlerts.get(i).getAlertType() == Alert.AlertType.NO_CLEARANCE
						&& !(currentAlerts.get(i).isInside())) {

					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
							//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());							
							return currentAlerts.get(i);
						}
					}
					
				//Check for latching - If we got one outside we should 
				//persist it if the condition still exists
				}else if(currentAlerts.get(i).getAlertType() == Alert.AlertType.NO_CLEARANCE
						&& currentAlerts.get(i).isInside() && currentAlerts.get(i).isPersistent()){
					
					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
							//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());							
							return currentAlerts.get(i);
						}
					}
				
				
				}
			}
			
			//If any runways tested true for crossing + inside, then issue crossing
			for (int i = 0; i < currentAlerts.size(); i++) {

				if (currentAlerts.get(i).getAlertType() == Alert.AlertType.CROSSING
						&& currentAlerts.get(i).isInside()) {

					for (RunwayZone rwy : rwyMgr.runways) {

						if (rwy.getName().equalsIgnoreCase(
								currentAlerts.get(i).getRunway())) {
							rwy.setAlert(currentAlerts.get(i).getAlertType());
							//Log.d(MainActivity.LOG_TAG, "Returning Alert: " + currentAlerts.get(i).getRunway() + " -- " + currentAlerts.get(i).getAlertType().name());
							return currentAlerts.get(i);
						}
					}
					
				}
			}

			//Log.d(MainActivity.LOG_TAG, "Returning Alert: Null - No alert tests passed");			
			return null;
		}
	}

	public void clearPastAlerts() {
		currentAlerts.clear();
	}

	public void setPositionAndHold(boolean b) {
		this.positionAndHold = b;

	}

}
