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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.SocketException;
import java.net.UnknownHostException;

import org.apache.commons.net.ftp.FTPClient;

import android.content.Context;
import android.location.Location;
import android.provider.Settings.Secure;
import com.mitre.holdshort.Alert.AlertType;

public class AlertLogger {

	/*
	 * This class is for the beta test only.
	 * 
	 * It is used for recording the state information and user feedback each
	 * time an alert is displayed, hidden or changed.
	 */

	public enum AlertResponse {
		NO_RESPONSE, GOOD_ALERT, BAD_ALERT, LATE_ALERT, EARLY_ALERT
	}

	public enum AlertEndType {
		NEW_ALERT, CLEARED_ALERT, SYSTEM_EXIT
	}

	private LoggedAlert currentAlert = null;
	private FTPClient alertFTPClient;
	private Context ctx;
	private String airport;
	public static String ftpHost = "PATH.TO.FTP_SERVER";
	public static String ftpUser = "FTP_USER";
	public static String ftpPassword = "FTP_PASSWORD";

	public AlertLogger(String airport, Context ctx) {

		this.ctx = ctx;
		this.airport = airport;
		try {

			alertFTPClient = new FTPClient();
			alertFTPClient.connect(ftpHost, 21);
			alertFTPClient.login(ftpUser, ftpPassword);
			alertFTPClient.enterLocalPassiveMode();

		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (UnknownHostException e) {
			System.err.println("No Connection For FTP Client");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// Check for or create old alert file for when FTPClient cannot connect
		File oldAlerts = new File(ctx.getFilesDir() + "/oldAlerts.dat");
		if (!(oldAlerts.exists())) {
			try {
				oldAlerts.createNewFile();
			} catch (IOException e1) {

			}
		}else{
			//Old Alert file exists & push old alerts to the ftp server
			logOldAlerts();
		}

	}

	public void startAlert(Location loc, AlertType alertType, String runway, String airport) {

		if (currentAlert != null) {
			clearAlert(loc, AlertEndType.NEW_ALERT);
		}
		currentAlert = new LoggedAlert(
				Secure.getString(ctx.getContentResolver(), Secure.ANDROID_ID),
				System.currentTimeMillis(), String.valueOf(loc.getLatitude()), String.valueOf(loc.getLongitude()), loc.getBearing(),
				(float) (loc.getSpeed() * MainActivity.MS_TO_KNOTS), loc.getAltitude()
						* MainActivity.M_TO_FEET, alertType, runway, airport);

	}

	public void setPilotResponse(AlertResponse response) {
		currentAlert.setResponse(response);
	}

	private void endAlert(Location loc, AlertEndType endType) {

		currentAlert.setStopTime(System.currentTimeMillis());
		currentAlert.setStopLatLon(String.valueOf(loc.getLatitude()),String.valueOf(loc.getLongitude()));
		currentAlert.setStopHeading(loc.getBearing());
		currentAlert.setStopSpeed((float) (loc.getSpeed() * MainActivity.MS_TO_KNOTS));
		currentAlert.setStopAltitude(loc.getAltitude() * MainActivity.M_TO_FEET);
		currentAlert.setEndType(endType);

		try {
			alertFTPClient.connect(this.ftpHost, 21);
			if (alertFTPClient.login(this.ftpUser, this.ftpPassword)) {
				alertFTPClient.enterLocalPassiveMode();
				writeDataToFtpServer(currentAlert);
				currentAlert = null;
			}

		} catch (UnknownHostException e) {
			System.err.println("No Connection For FTP Client");

			// No write that stuff to oldAlerts.dat
			File oldAlerts = new File(ctx.getFilesDir() + "/oldAlerts.dat");
			FileWriter logWriter = null;
			try {
				logWriter = new FileWriter(oldAlerts, true);
				BufferedWriter outer = new BufferedWriter(logWriter);
				outer.append(currentAlert.getAlertString());
				outer.newLine();
				outer.close();
				System.out.println(String.valueOf(oldAlerts.length()));

			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("No Connection For FTP Client");

			// No write that stuff to oldAlerts.dat
			File oldAlerts = new File(ctx.getFilesDir() + "/oldAlerts.dat");
			FileWriter logWriter = null;
			try {
				logWriter = new FileWriter(oldAlerts, true);
				BufferedWriter outer = new BufferedWriter(logWriter);
				outer.append(currentAlert.getAlertString());
				outer.newLine();
				outer.close();
				System.out.println(String.valueOf(oldAlerts.length()));

			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

		}

	}

	public void writeDataToFtpServer(LoggedAlert currentAlert) {
		try {
			alertFTPClient.changeWorkingDirectory("/data");
			OutputStream os = alertFTPClient.storeFileStream(airport + "_"
					+ System.currentTimeMillis() + ".dat");
			OutputStreamWriter osw = new OutputStreamWriter(os);
			osw.write(currentAlert.getAlertString());
			osw.close();
			logOldAlerts();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void clearAlert(Location loc, AlertEndType endType) {

		if (currentAlert != null) {
			endAlert(loc, endType);
			currentAlert = null;
		}

	}

	class LoggedAlert {

		// State info at start of alert
		private long startTime;
		private String startLat;
		private String startLon;
		private float startHeading;
		private float startSpeed;
		private double startAltitude;

		// State info at end of alert
		private long stopTime;
		private String stopLat;
		private String stopLon;
		private float stopHeading;
		private float stopSpeed;
		private double stopAltitude;

		// Alert Type
		private Alert.AlertType alertType;

		// Pilot feedback response
		// 0 = no response (Default), 1 = bad alert, 2 = good alert
		private AlertResponse response = AlertResponse.NO_RESPONSE;

		private String runway = "";
		private String userID;
		private String currentAirport;
		private AlertEndType endType;

		public LoggedAlert(String userID, long startTime, String startLat, String startLon, float startHeading,
				float startSpeed, double startAltitude, Alert.AlertType alertType, String runway,
				String airport2) {
			super();
			this.userID = userID;
			this.startTime = startTime;
			this.startLat = startLat;
			this.startLon = startLon;			
			this.startHeading = startHeading;
			this.startSpeed = startSpeed;
			this.startAltitude = startAltitude;
			this.alertType = alertType;
			this.runway = runway;
			this.currentAirport = airport2;
		}

		public String getAlertString() {

			StringBuffer alert = new StringBuffer();
			alert.append(this.userID + ",");
			alert.append(this.startTime + ",");
			alert.append(this.startLat + ",");
			alert.append(this.startLon + ",");
			alert.append(this.startHeading + ",");
			alert.append(this.startSpeed + ",");
			alert.append(this.startAltitude + ",");
			alert.append(this.stopTime + ",");
			alert.append(this.stopLat + ",");
			alert.append(this.stopLon + ",");
			alert.append(this.stopHeading + ",");
			alert.append(this.startSpeed + ",");
			alert.append(this.startAltitude + ",");
			alert.append(this.alertType.name() + ",");
			alert.append(this.response.name() + ",");
			alert.append(this.currentAirport + ",");
			alert.append(this.runway + ",");
			alert.append(this.endType.name());
			return alert.toString();
		}

		public long getStartTime() {

			return startTime;
		}

		public void setStartTime(long startTime) {
			this.startTime = startTime;
		}

		public String getStartLatLon() {
			return startLat + "/" + startLon;
		}

		public void setStartLatLon(String startLat, String startLon) {
			this.startLat = startLat;
			this.startLon = startLon;
		}

		public float getStartHeading() {
			return startHeading;
		}

		public void setStartHeading(float startHeading) {
			this.startHeading = startHeading;
		}

		public float getStartSpeed() {
			return startSpeed;
		}

		public void setStartSpeed(float startSpeed) {
			this.startSpeed = startSpeed;
		}

		public double getStartAltitude() {
			return startAltitude;
		}

		public void setStartAltitude(double startAltitude) {
			this.startAltitude = startAltitude;
		}

		public long getStopTime() {
			return stopTime;
		}

		public void setStopTime(long stopTime) {
			this.stopTime = stopTime;
		}

		public String getStopLatLon() {
			return stopLat + "/" + stopLon;
		}

		public void setStopLatLon(String stopLat, String stopLon) {
			this.stopLat = stopLat;
			this.stopLon = stopLon;
		}

		public float getStopHeading() {
			return stopHeading;
		}

		public void setStopHeading(float stopHeading) {
			this.stopHeading = stopHeading;
		}

		public float getStopSpeed() {
			return stopSpeed;
		}

		public void setStopSpeed(float stopSpeed) {
			this.stopSpeed = stopSpeed;
		}

		public double getStopAltitude() {
			return stopAltitude;
		}

		public void setStopAltitude(double stopAltitude) {
			this.stopAltitude = stopAltitude;
		}

		public AlertType getAlertType() {
			return alertType;
		}

		public void setAlertType(AlertType alertType) {
			this.alertType = alertType;
		}

		public AlertResponse getResponse() {
			return response;
		}

		public void setResponse(AlertResponse pilotResponse) {
			this.response = pilotResponse;
		}

		public String getRunway() {
			return runway;
		}

		public void setRunway(String runway) {
			this.runway = runway;
		}

		public void setAirport(String airport) {
			this.currentAirport = airport;
		}

		public String getAirport() {
			return this.currentAirport;
		}

		public void setEndType(AlertEndType endType) {
			this.endType = endType;
		}

	}
	
	public void logOldAlerts(){
		try {
			// check for old alerts
			File oldAlerts = new File(ctx.getFilesDir() + "/oldAlerts.dat");

			if (oldAlerts.length() > 0) {
				
				alertFTPClient.changeWorkingDirectory("/data");
				OutputStream os = alertFTPClient.storeFileStream(airport + "_"
						+ System.currentTimeMillis() + ".dat");
				OutputStreamWriter osw = new OutputStreamWriter(os);
				BufferedReader br = new BufferedReader(new FileReader(oldAlerts));
				String line;
				while ((line = br.readLine()) != null) {
					osw.write(line);
					osw.write("\n");
				}

				// clear oldAlerts.dat
				FileWriter clearOldAlerts = new FileWriter(oldAlerts, false);
				clearOldAlerts.write("");
				clearOldAlerts.close();				
				osw.close();
			}
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
