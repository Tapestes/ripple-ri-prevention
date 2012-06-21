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
import android.location.Location;

public class RunwayZone {

	Point pointA;
	Point pointB;
	Point pointC;
	Point pointD;
	String name;
	String speechName;
	Alert.AlertType alert = null;
	RunwayBar bar;
	double maxLat;
	double minLat;
	double maxLon;
	double minLon;
	int heading1;
	int heading2;
	private volatile Boolean crossAlert = false;
	private volatile Boolean holdShortAlert = false;
	private volatile Boolean enteringAlert = false;
	private volatile Boolean wrongRwyAlert = false;
	Point[][] borders;
	List<Point> polyBounds;

	public RunwayZone() {
		polyBounds = new ArrayList<Point>();
	}

	public void addPoint(Point point) {
		polyBounds.add(point);
	}

	public void setPointALat(double latitude) {

		pointA.setLatitude(latitude);
	}

	public void setPointALon(double longitude) {

		pointA.setLongitude(longitude);
	}

	public void setPointBLat(double latitude) {

		pointB.setLatitude(latitude);
	}

	public void setPointBLon(double longitude) {

		pointB.setLongitude(longitude);
	}

	public String getSpeechName() {
		return speechName;
	}

	public void setSpeechName(String speechName) {
		this.speechName = speechName;
	}

	public void setPointCLat(double latitude) {

		pointC.setLatitude(latitude);
	}

	public void setPointCLon(double longitude) {

		pointC.setLongitude(longitude);
	}

	public void setPointDLat(double latitude) {

		pointD.setLatitude(latitude);
	}

	public void setPointDLon(double longitude) {

		pointD.setLongitude(longitude);
		createBoundExtremes();
		createBorders();
	}

	private void createBorders() {
		borders = new Point[4][2];
		borders[0][0] = pointA;
		borders[0][1] = pointB;
		borders[1][0] = pointB;
		borders[1][1] = pointC;
		borders[2][0] = pointC;
		borders[2][1] = pointD;
		borders[3][0] = pointD;
		borders[3][1] = pointA;
		createPolyBounds();
	}

	private void createPolyBounds() {
		polyBounds = new ArrayList<Point>();
		polyBounds.add(pointA);
		polyBounds.add(pointB);
		polyBounds.add(pointC);
		polyBounds.add(pointD);
	}

	public List<Point> getPolyBounds() {
		return this.polyBounds;
	}

	private void createBoundExtremes() {

		// Find max Lat
		double maxLat1 = Math.max(pointA.getLatitude(), pointB.getLatitude());
		double maxLat2 = Math.max(maxLat1, pointC.getLatitude());
		maxLat = Math.max(maxLat2, pointD.getLatitude());

		// Find min Lat
		double minLat1 = Math.max(pointA.getLatitude(), pointB.getLatitude());
		double minLat2 = Math.max(maxLat1, pointC.getLatitude());
		minLat = Math.max(maxLat2, pointD.getLatitude());

		// Find max Lon
		double maxLon1 = Math.max(pointA.getLongitude(), pointB.getLongitude());
		double maxLon2 = Math.max(maxLon1, pointC.getLongitude());
		maxLon = Math.max(maxLon2, pointD.getLongitude());

		// Find max Lon
		double minLon1 = Math.max(pointA.getLongitude(), pointB.getLongitude());
		double minLon2 = Math.max(minLon1, pointC.getLongitude());
		minLon = Math.max(minLon2, pointD.getLongitude());

	}

	public Boolean inRunwayZone(Location loc) {

		double lat = loc.getLatitude();
		double lon = loc.getLongitude();

		if (lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon) {
			return true;
		} else {
			return false;
		}

	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setRunwayBar(RunwayBar bar) {
		this.bar = bar;
	}

	public RunwayBar getRunwayBar() {
		return bar;
	}

	public void setBaseHeading(int heading) {
		this.heading1 = heading;
	}

	public void setReciprocalHeading(int heading) {
		this.heading2 = heading;
	}

	public Boolean getCrossAlert() {
		return crossAlert;
	}

	public void setCrossAlert(Boolean crossAlert) {
		this.crossAlert = crossAlert;
	}

	public Boolean getHoldShortAlert() {
		return holdShortAlert;
	}

	public void setHoldShortAlert(Boolean holdShortAlert) {
		this.holdShortAlert = holdShortAlert;
	}

	public Boolean getEnteringAlert() {
		return enteringAlert;
	}

	public void setEnteringAlert(Boolean enteringAlert) {
		this.enteringAlert = enteringAlert;
	}

	public Boolean getWrongRwyAlert() {
		return wrongRwyAlert;
	}

	public void setWrongRwyAlert(Boolean wrongRwyAlert) {
		this.wrongRwyAlert = wrongRwyAlert;
	}

	public Point getPointA() {
		return pointA;
	}

	public Point getPointB() {
		return pointB;
	}

	public Point getPointC() {
		return pointC;
	}

	public Point getPointD() {
		return pointD;
	}

	public Alert.AlertType getAlert() {
		return this.alert;
	}

	public void setAlert(Alert.AlertType alert) {
		this.alert = alert;

	}

}
