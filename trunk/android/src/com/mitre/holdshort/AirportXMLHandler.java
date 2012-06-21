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

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import android.location.Location;


public class AirportXMLHandler extends DefaultHandler {

	private StringBuffer buff = null;
	boolean insideAirport = false;
	boolean insideQuad = false;
	boolean insideLat = false;
	boolean insideLon = false;
	boolean buffering = false;
	private Location loc;
	private Airport airport;
	private Location myLocation;
	private boolean getRunwayInfo = false;
	private RunwayZone runway;

	private List<Airport> airportList;
	private String closestAirport;
	private RunwayManager rwyMgr;
	private String myQuad;

	public AirportXMLHandler(Location location, RunwayManager rwyMgr) {
		this.myLocation = location;
		this.rwyMgr = rwyMgr;
		airportList = new ArrayList<Airport>();
		myQuad = myQuad();
	}

	@Override
	public void startDocument() throws SAXException {
		
	}

	@Override
	public void startElement(String namespaceURI, String localName, String qName, Attributes atts)
			throws SAXException {
		
			
		if (localName.equals("quad")) {

			
			if (atts.getValue("id").equals(myQuad)) {
				insideQuad = true;
			} else {
				insideQuad = false;
			}

		}

		if (insideQuad) {
			if (localName.equals("airport")) {
				insideAirport = true;
				loc = new Location(atts.getValue("id"));
				
			}

			if (insideAirport) {
				if (insideAirport && localName.equals("latitude")) {
					buff = new StringBuffer("");
					buffering = true;
				}

				if (insideAirport && localName.equals("longitude")) {
					buff = new StringBuffer("");
					buffering = true;
				}

				if (getRunwayInfo) {
					if (localName.equals("runway")) {
						runway = new RunwayZone();
						runway.setName(atts.getValue("id"));
					}
					if (localName.equals("runwayName")) {
						buff = new StringBuffer("");
						buffering = true;
					}
					if (localName.equals("runwayBaseOrientation")) {
						buff = new StringBuffer("");
						buffering = true;
					}
					if (localName.equals("runwayReciprocalOrientation")) {
						buff = new StringBuffer("");
						buffering = true;
					}
					if (localName.equals("coordinates")) {
						buff = new StringBuffer("");
						buffering = true;
					}
				}
			}
		}
	}

	@Override
	public void characters(char[] ch, int start, int length) throws SAXException {

		if (buffering) {
			buff.append(ch, start, length);

		}

	}

	@Override
	public void endElement(String namespaceURI, String localName, String qName) throws SAXException {

		if (insideAirport && getRunwayInfo && localName.equals("runwayBaseOrientation")) {
			runway.setBaseHeading(Integer.parseInt(buff.toString()));
			buffering = false;
		}
		if (insideAirport && getRunwayInfo && localName.equals("runwayReciprocalOrientation")) {
			runway.setReciprocalHeading(Integer.parseInt(buff.toString()));
			buffering = false;
		}
		if (insideAirport && getRunwayInfo && localName.equals("coordinates")) {
			buffering = false;
			processPoints(buff);
		}
		
		if (insideAirport && getRunwayInfo && localName.equals("runwayName")) {
			buffering = false;
			runway.setSpeechName(buff.toString());
		}
		if (insideAirport && getRunwayInfo && localName.equals("runway")) {
			airport.getRunwayList().add(runway);
		}

		if (insideAirport && localName.equals("airport")) {

			insideAirport = false;
			buffering = false;

			// check if we were getting runway info
			// if so, then we can exit now

			if (getRunwayInfo) {

				if (airport.getRunwayList().size() == 0) {
					airport.setName(airport.getName() + "_NS");
					airportList.add(airport);
				} else {
					airportList.add(airport);
				}
			}
		}

		if (insideAirport && localName.equals("latitude")) {
			buffering = false;
			loc.setLatitude(Double.parseDouble(buff.toString()));

		}

		if (insideAirport && localName.equals("longitude")) {
			buffering = false;
			loc.setLongitude(Double.parseDouble(buff.toString()));

			// Now test and see if we need to go any further for this airport

			// If we're in the lab then check if SFO

			if ((loc.distanceTo(myLocation)) * MainActivity.METERS_TO_MILES < 5) {
				airport = new Airport(loc.getProvider(), loc);
				getRunwayInfo = true;
			} else {
				getRunwayInfo = false;
			}

		}
	}

	@Override
	public void endDocument() throws SAXException {

	}

	public String getAirport() {

		
		if (airportList.isEmpty()) {
			closestAirport = null;
		} else {

			if (airportList.size() == 1) {
				closestAirport = airportList.get(0).getName();
				rwyMgr.runways = airportList.get(0).getRunwayList();
			} else {

				closestAirport = airportList.get(0).getName();
				rwyMgr.runways = airportList.get(0).getRunwayList();
				float closest = airportList.get(0).getLocation().distanceTo(myLocation);
				for (int i = 1; i < airportList.size(); i++) {

					if (airportList.get(i).getLocation().distanceTo(myLocation) < closest) {
						closestAirport = airportList.get(i).getName();
						rwyMgr.runways = airportList.get(i).getRunwayList();
					}

				}
			}
		}

		return closestAirport;
	}

	private void processPoints(StringBuffer buff2) {
		String points[] = buff2.toString().split(" ");

		for (int i = 0; i < points.length; i++) {

			String pointParts[] = points[i].split(",");

			if (pointParts.length < 2) {
			
			} else {

				Point newPoint = new Point(Double.parseDouble(pointParts[1]),
						Double.parseDouble(pointParts[0]));
				runway.addPoint(newPoint);
			}

		}

	}

	private String myQuad() {

		if (myLocation.getLatitude() > 40 && myLocation.getLongitude() < -100) {
			return "NW";
		}
		if (myLocation.getLatitude() > 40 && myLocation.getLongitude() > -100) {
			return "NE";
		}
		if (myLocation.getLatitude() < 40 && myLocation.getLongitude() < -100) {
			return "SW";
		}
		if (myLocation.getLatitude() < 40 && myLocation.getLongitude() > -100) {
			return "SE";
		}
		return null;

	}

}
