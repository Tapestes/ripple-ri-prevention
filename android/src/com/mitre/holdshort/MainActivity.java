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

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.SocketException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Timer;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

import com.mitre.holdshort.Alert.AlertType;
import com.mitre.holdshort.AlertLogger.AlertResponse;

public class MainActivity extends Activity {

	// General Stuff
	public static final String LOG_TAG = "RIPPLE";
	private static final String PREFS_NAME = "com.mitre.org.holdshort.HoldShortPrefs";

	// Mathematical Conversions & Constants
	public static final double MS_TO_KNOTS = 1.9438444924406;
	public static final double M_TO_FEET = 3.2808399;
	public static final double METERS_TO_MILES = .000621371192;
	public static final double radius = 3440.07; // radius of the earth in nmi
	public static final double threshold = 5;

	// Activity Result IDs
	protected static final int TAXI_CLEARANCE = 1;

	// GUI Items
	private AirportPlateView plateView;
	private TextView taxiClearance;
	private ImageButton infoBtn;
	private TextView openClose;
	private LinearLayout runwayContainer;
	private TextView airportID;
	private RelativeLayout summaryBar;
	private RelativeLayout summaryInfo;
	private ImageButton taxiBtn;
	private TextView summary_index;

	private TextView summary_thumb;
	private LinearLayout holdShort;
	private LinearLayout noClearance;
	private LinearLayout crossingAlert;
	private LinearLayout noTakeoffClearance;
	private TextView depRwyBtn;
	private RelativeLayout header;
	private TextView goodAlert;
	private TextView badAlert;
	private LinearLayout betaControls;
	private SlidingPanel slidingPanel;
	private View headerDropShadow;

	// state information
	private Boolean allSetUp = false;
	private Boolean waiverAccept = false;
	private Boolean increase = false;
	private String depRunway = null;
	private String airport;
	private int summaryIndex = 0;
	private Boolean auralAlerts;
	private Point myPosition;
	private double currentLat;
	private double currentLon;
	private float currentSpd;
	private float currentHdg;
	private Boolean lab = false;
	private int soundNum = 0;
	private double currentAlt;
	private Location currentLocation;

	// Other management objects
	private Timer openCloseTimer;
	private RunwayManager rwyMgr;
	private ProgressDialog loadDialog;
	private LocationManager lm;
	private LocationListener locationListener;
	private List<RunwayBar> runwayList = new ArrayList<RunwayBar>();
	private List<String> sounds = new ArrayList<String>();
	private MediaPlayer mp;
	private SharedPreferences settings;
	private DepRwyDialog depRwyDialog;
	private AlertLogger alertLogger;
	private RelativeLayout alertScreen;
	private TextView miniAlert;
	private AlertType currentAlert = null;
	private GestureDetector summaryGestureDetector;
	private AlertManager alertManager;
	private TextView startMsg;
	private ProgressBar startProgress;
	private String[] instructionArray;
	private ArrayList<String> instructionList;
	private Button startButton;
	private long startTime;
	private LinearLayout innerHolder;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		startTime = System.currentTimeMillis();
		getWindow().setFormat(PixelFormat.RGBA_8888);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_DITHER);
		// No need to have the title bar. Just takes up space
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Let's first check the date/time and see if we're
		// within the time frame of the app

		// Set up expiration date
		Calendar cal = new GregorianCalendar(2012, 1, 1);

		// Check and make sure the consent has been agreed to
		settings = getSharedPreferences(PREFS_NAME, 0);
		if (settings.getBoolean("consent", false)) {
			waiverAccept = true;
			startUp();
		} else {
			showDisclaimer();
		}

	}

	private void startUp() {

		lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		locationListener = new MyLocationListener();
		checkGPSSettings();

	}

	private void showDisclaimer() {

		final Dialog dialog = new Dialog(MainActivity.this);
		OnClickListener disclaimerBtnClick;

		dialog.setContentView(R.layout.legal_stuff_dialog);
		dialog.setTitle("RIPPLE - Informed Consent");
		dialog.setCancelable(false);
		dialog.getWindow().setLayout(ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);

		TextView consent = (TextView) dialog.findViewById(R.id.disclaimerAccept);
		TextView reject = (TextView) dialog.findViewById(R.id.disclaimerReject);

		disclaimerBtnClick = new OnClickListener() {

			@Override
			public void onClick(View v) {

				if (v.getId() == R.id.disclaimerAccept) {
					settings.edit().putBoolean("consent", true).commit();
					dialog.dismiss();
					waiverAccept = true;
					startUp();
				} else {
					finish();
				}

			}

		};

		consent.setOnClickListener(disclaimerBtnClick);
		reject.setOnClickListener(disclaimerBtnClick);
		dialog.show();

	}

	private void checkGPSSettings() {

		setContentView(R.layout.startup_screen);

		startMsg = (TextView) findViewById(R.id.startMsg);
		startButton = (Button) findViewById(R.id.startButton);
		startButton.setOnClickListener(enableGPSButtonListener);
		startProgress = (ProgressBar) findViewById(R.id.startProgress);

		if (lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
			startMsg.setText("Aquiring GPS Location...");
			startProgress.setVisibility(View.VISIBLE);
			startButton.setVisibility(View.GONE);
			lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 1, locationListener);
		} else {
			startMsg.setText("This application requires the use of GPS.");
			startProgress.setVisibility(View.GONE);
			startButton.setVisibility(View.VISIBLE);
		}
	}

	private OnClickListener navControlListener = new OnClickListener() {

		@Override
		public void onClick(View arg0) {

			// Tell the plateView to snap back so ownship is
			// within the frame
			plateView.showOwnship(true);
		}

	};

	private OnClickListener enableGPSButtonListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Intent gpsOptionsIntent = new Intent(
					android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
			startActivity(gpsOptionsIntent);
		}

	};

	private TextView lateAlert;
	private TextView earlyAlert;
	private boolean announceRWY;

	private ImageView speechBtn;

	private ImageView navControl;

	private LinearLayout disabled;

	private ImageHelper imageHelper;

	private LinearLayout disabled_gps;

	private LinearLayout disabled_speed;

	private void startMainActivity() {

		// Set screen layout
		setContentView(R.layout.main);
		imageHelper = new ImageHelper();
		summaryGestureDetector = new GestureDetector(new summaryGester());

		// Get Reference to Shared Preferences file
		auralAlerts = settings.getBoolean("auralAlerts", true);
		settings.edit().putBoolean("auralAlerts", auralAlerts);
		announceRWY = settings.getBoolean("announceRWY", true);
		settings.edit().putBoolean("announceRWY", announceRWY);

		// Airport ID
		airportID = (TextView) findViewById(R.id.airportID);
		airportID.setText("K" + airport);

		// SpeechButton
		speechBtn = (ImageView) findViewById(R.id.speechBtn);
		speechBtn.setOnClickListener(speechBtnClickListener);

		// Get open close button
		openClose = (TextView) findViewById(R.id.openClose);
		openClose.setText("close");
		// openClose.setTextColor(Color.argb(200, 255, 255, 255));
		openClose.setOnClickListener(openCloseListener);

		// departure runway button
		depRwyBtn = (TextView) findViewById(R.id.depRwyBtn);
		depRwyBtn.setOnClickListener(depRwyListener);
		depRwyBtn.setText("Departure Rwy");
		depRwyBtn.setBackgroundResource(R.drawable.hatched_small_bg_layer);
		depRwyBtn.setPadding(10, 5, 10, 5);

		// info button - used to start prefs activity
		infoBtn = (ImageButton) findViewById(R.id.info_btn);
		// infoBtn.setBackgroundColor(Color.rgb(0,0,0));
		infoBtn.setOnClickListener(settingsMenuListener);

		// taxi button - used to start Taxi instruction activity
		taxiBtn = (ImageButton) findViewById(R.id.taxi_btn);
		// taxiBtn.setBackgroundColor(Color.rgb(0,0,0));
		taxiBtn.setOnClickListener(taxiBtnListener);

		// summary info - when drawer is closed
		summaryBar = (RelativeLayout) findViewById(R.id.summaryBar);
		summaryBar.setOnTouchListener(summaryTouchListener);
		runwayContainer = (LinearLayout) findViewById(R.id.holder);
		innerHolder = (LinearLayout) findViewById(R.id.innerHolder);
		slidingPanel = (SlidingPanel) findViewById(R.id.slidingDrawer);

		// header
		header = (RelativeLayout) findViewById(R.id.header);
		headerDropShadow = (View) findViewById(R.id.header_drop_shadow);
		slidingPanel.setHeaderDropShadow(headerDropShadow);
		slidingPanel.setRunwayContainer(runwayContainer);
		slidingPanel.setOpenCloseTextView(openClose);
		slidingPanel.setHandler(this.handler);

		summaryInfo = (RelativeLayout) findViewById(R.id.summary_info);
		summary_index = (TextView) findViewById(R.id.summary_index);
		summary_thumb = (TextView) findViewById(R.id.summary_thumb);
		summary_thumb.setWidth(90);

		// Taxi path area
		taxiClearance = (TextView) findViewById(R.id.taxiClearance);
		taxiClearance.setTextSize(12);
		taxiClearance.setPadding(5, 0, 5, 0);
		taxiClearance.setTextColor(Color.WHITE);
		// taxiClearance.setBackgroundColor(Color.rgb(0,0,0));
		taxiClearance.setOnClickListener(taxiPathListener);

		// Airport Diagram
		plateView = (AirportPlateView) findViewById(R.id.plateView);
		// Set up the nav control for the moving map
		// this is used when ownship is off screen
		navControl = (ImageView) findViewById(R.id.showNavBtn);
		plateView.setNavControls(navControl);
		navControl.setVisibility(ImageView.INVISIBLE);
		navControl.setOnClickListener(navControlListener);

		// // Lat/Lon Ref 1 SFO
		Point latLon1 = new Point(37.627827, -122.366794);
		Point latLon2 = new Point(37.606827, -122.380724);
		XYPoint xy1 = new XYPoint(134, 173);
		XYPoint xy2 = new XYPoint(340, 281);

		// Lat/Lon Ref 1 HEF
		// Point latLon1 = new Point(38.727680,-77.518803);
		// Point latLon2 = new Point(38.714041,-77.508976);
		// XYPoint xy1 = new XYPoint(140,187);
		// XYPoint xy2 = new XYPoint(322,513);
		plateView.geoReference(latLon1, latLon2, xy1, xy2);

		Location loc = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		plateView.updatePosition(loc.getBearing(), loc.getLatitude(), loc.getLongitude());

		// navView.setScroll(plateView);
		TextView emptyPlate = (TextView) findViewById(R.id.emptyPlate);

		if (!(plateView.setImage(airport))) {
			// Place holder if no plate is available
			emptyPlate.setVisibility(View.VISIBLE);
			plateView.setVisibility(View.GONE);

		} else {
			// Show plate. Hide placeholder
			plateView.setImage(airport);
			emptyPlate.setVisibility(View.GONE);
		}

		// Create logger for alerts
		alertLogger = new AlertLogger(airport, MainActivity.this);

		// Alert Panels
		alertScreen = (RelativeLayout) findViewById(R.id.alertScreen);
		betaControls = (LinearLayout) findViewById(R.id.betaControls);
		goodAlert = (TextView) findViewById(R.id.goodAlert);
		goodAlert.setOnClickListener(alertResponseListener);
		badAlert = (TextView) findViewById(R.id.badAlert);
		badAlert.setOnClickListener(alertResponseListener);
		lateAlert = (TextView) findViewById(R.id.lateAlert);
		lateAlert.setOnClickListener(alertResponseListener);
		earlyAlert = (TextView) findViewById(R.id.earlyAlert);
		earlyAlert.setOnClickListener(alertResponseListener);

		miniAlert = (TextView) findViewById(R.id.miniAlertText);
		miniAlert.setOnClickListener(maximizeAlert);

		holdShort = (LinearLayout) findViewById(R.id.holdShort);
		holdShort.getChildAt(0).setBackgroundDrawable(
				imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.alert), 10));
		holdShort.setOnClickListener(minimizeAlert);
		noClearance = (LinearLayout) findViewById(R.id.noClearance);
		noClearance.setOnClickListener(minimizeAlert);
		noClearance.getChildAt(0).setBackgroundDrawable(
				imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.alert), 10));
		crossingAlert = (LinearLayout) findViewById(R.id.crossingAlert);
		noTakeoffClearance = (LinearLayout) findViewById(R.id.noTakeoffClearance);
		noTakeoffClearance.getChildAt(0).setBackgroundDrawable(
				imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.alert), 10));
		noTakeoffClearance.setOnClickListener(minimizeAlert);
		disabled_gps = (LinearLayout) findViewById(R.id.disabled_gps);
		disabled_gps.getChildAt(0).setBackgroundDrawable(
				imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.disabled), 10));
		disabled_gps.setOnClickListener(minimizeAlert);

		disabled_speed = (LinearLayout) findViewById(R.id.disabled_speed);
		disabled_speed.getChildAt(0).setBackgroundDrawable(
				imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.disabled), 10));
		disabled_speed.setOnClickListener(minimizeAlert);

		// Instantiate media player & set completion listener
		mp = new MediaPlayer();
		mp.setOnCompletionListener(alertPlaybackListener);

		// Instruction List instantiation
		instructionList = new ArrayList<String>();

		setUpRunways();
		slidingPanel.setOnTouchListener(summaryTouchListener);
		// Instantiate Alert Manager
		alertManager = new AlertManager(rwyMgr);

		allSetUp = true;
	}

	private class MyLocationListener implements LocationListener {

		private boolean findInitialLocation = true;

		@Override
		public void onLocationChanged(Location loc) {

			currentLocation = loc;

			if (findInitialLocation) {
				findInitialLocation = false;
				startMsg.setText("Finding Closest Airport...");
				new findClosestAirport().execute(loc);
			} else {

				if (allSetUp) {
					if (loc != null) {

						if (loc.hasAccuracy()) {
							if (loc.getAccuracy() > 15) {
								if ((disabled_gps.getVisibility() == View.VISIBLE)
										|| (miniAlert.getVisibility() == View.VISIBLE && miniAlert
												.getText().toString()
												.equalsIgnoreCase("Reminders Disabled"))) {
									// Do nothing alert is already showing
								} else {
									showAlert(Alert.AlertType.BAD_GPS, null);
								}
								return;
							}
						}

						if (loc.hasSpeed()) {
							if (loc.getSpeed() * MS_TO_KNOTS > 25) {

								if ((disabled_speed.getVisibility() == View.VISIBLE)
										|| (miniAlert.getVisibility() == View.VISIBLE && miniAlert
												.getText().toString()
												.equalsIgnoreCase("Reminders Disabled"))) {
									// Do nothing alert is already showing
								} else {
									showAlert(Alert.AlertType.BAD_GPS, null);
								}
								return;
							}
						}

						Log.d("New Position", "New Position");
						plateView.updatePosition(loc.getBearing(), loc.getLatitude(),
								loc.getLongitude());
						checkForAlert(loc);

					}

				}
			}

		}

		@Override
		public void onProviderDisabled(String provider) {

		}

		@Override
		public void onProviderEnabled(String provider) {

		}

		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {

		}

	}

	private OnClickListener alertResponseListener = new OnClickListener() {

		@Override
		public void onClick(View v) {

			if (v.getId() == R.id.goodAlert) {
				alertLogger.setPilotResponse(AlertResponse.GOOD_ALERT);
			}

			if (v.getId() == R.id.badAlert) {
				alertLogger.setPilotResponse(AlertResponse.BAD_ALERT);
			}

			if (v.getId() == R.id.earlyAlert) {
				alertLogger.setPilotResponse(AlertResponse.EARLY_ALERT);
			}

			if (v.getId() == R.id.lateAlert) {
				alertLogger.setPilotResponse(AlertResponse.LATE_ALERT);
			}

			betaControls.setVisibility(RelativeLayout.GONE);
		}

	};

	protected boolean speech = true;

	protected void showAlert(Alert.AlertType alertType, String runway) {

		if (alertType == null) {
			alertScreen.setVisibility(RelativeLayout.GONE);
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong Runway
			miniAlert.setVisibility(View.GONE);
			return;

		}

		alertScreen.setVisibility(RelativeLayout.VISIBLE);
		betaControls.setVisibility(RelativeLayout.GONE);

		if (alertType == Alert.AlertType.TOO_FAST) {
			miniAlert.setVisibility(View.GONE);
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.VISIBLE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching //
															// //Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong
			return;

		}

		if (alertType == Alert.AlertType.BAD_GPS) {
			miniAlert.setVisibility(View.GONE);
			disabled_gps.setVisibility(View.VISIBLE);
			disabled_speed.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching //
															// //Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong
			return;

		}

		if (alertType == Alert.AlertType.HOLD_SHORT) {
			miniAlert.setVisibility(View.GONE);
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.VISIBLE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching //
															// Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing
															// Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong
			return;

		}
		if (alertType == Alert.AlertType.CROSSING) {
			miniAlert.setVisibility(View.GONE);
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching
															// Runway
			crossingAlert.setVisibility(LinearLayout.VISIBLE); // Crossing
																// Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong
			return;
		}
		if (alertType == Alert.AlertType.NO_CLEARANCE) {
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.GONE);
			miniAlert.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.VISIBLE); // Approaching
																// Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing
															// Runway
			noTakeoffClearance.setVisibility(LinearLayout.GONE); // Wrong
			return;
		}
		if (alertType == Alert.AlertType.WRONG_RUNWAY) {
			disabled_gps.setVisibility(View.GONE);
			disabled_speed.setVisibility(View.GONE);
			miniAlert.setVisibility(View.GONE);
			holdShort.setVisibility(LinearLayout.GONE); // Hold Short
			noClearance.setVisibility(LinearLayout.GONE); // Approaching
															// //Runway
			crossingAlert.setVisibility(LinearLayout.GONE); // Crossing
															// Runway
			noTakeoffClearance.setVisibility(LinearLayout.VISIBLE); // Wrong
			return;
		}

	}

	private class findClosestAirport extends AsyncTask<Location, Void, String> {

		@Override
		protected String doInBackground(Location... params) {
			AirportXMLHandler airportXMLHandler = null;
			// Create runway manager
			rwyMgr = new RunwayManager();

			File sdCard = Environment.getExternalStorageDirectory();
			File holdShort = new File(sdCard.getAbsolutePath() + "/HoldShortApp/");
			if (!(holdShort.exists())) {
				holdShort.mkdir();
			}

			FTPClient alertFTPClient = new FTPClient();
			try {
				alertFTPClient.connect(AlertLogger.ftpHost, 21);
				alertFTPClient.login(AlertLogger.ftpUser, AlertLogger.ftpPassword);
				alertFTPClient.enterLocalPassiveMode();
			} catch (SocketException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			} catch (IOException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}

			File dir = new File(sdCard.getAbsolutePath() + "/HoldShortApp/surface_ripple.xml");
			if (!(dir.exists())) {
				try {
					dir.createNewFile();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}

				// Read the file from assets
				AssetManager mngr = getAssets();

				try {

					// Get input stream from surface_ripple
					// Had to rename file to .mp3 to get around .xml compression
					// and Android restriction
					InputStream is = mngr.open("surface_ripple.mp3");
					readFile(is, dir);

				} catch (IOException e) {
					e.printStackTrace();
				} catch (Exception e) {
					e.printStackTrace();
				}

			} else {
				// check if update available
				try {
					Log.d(MainActivity.LOG_TAG, "checking for update");
					alertFTPClient.changeWorkingDirectory("/assets");
					FTPFile[] files = alertFTPClient.listFiles();

					for (FTPFile file : files) {
						if (file.getName().equalsIgnoreCase("surface_ripple.xml")) {
							Log.d(MainActivity.LOG_TAG, "checking dates");
							Log.d(MainActivity.LOG_TAG,
									String.valueOf(file.getTimestamp().getTimeInMillis()));
							Log.d(MainActivity.LOG_TAG, String.valueOf(dir.lastModified()));

							if (file.getTimestamp().getTimeInMillis() > dir.lastModified()) {
								Log.d(MainActivity.LOG_TAG, "making new file...");
								dir.createNewFile();
								InputStream in = alertFTPClient
										.retrieveFileStream("surface_ripple.xml");
								BufferedOutputStream buffer = new BufferedOutputStream(
										new FileOutputStream(dir));
								byte byt[] = new byte[1024];

								int i;
								for (long l = 0L; (i = in.read(byt)) != -1; l += i) {
									buffer.write(byt, 0, i);
								}
								in.close();
								buffer.close();
							}

						}

					}
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			}

			// Set up parser and parse airport/runway xml file
			SAXParserFactory spf = SAXParserFactory.newInstance();
			SAXParser sp = null;
			try {
				sp = spf.newSAXParser();
				XMLReader xr = null;

				xr = sp.getXMLReader();
				airportXMLHandler = new AirportXMLHandler(params[0], rwyMgr);
				xr.setContentHandler(airportXMLHandler);

				xr.parse(new InputSource(new FileInputStream(Environment
						.getExternalStorageDirectory().getAbsolutePath()
						+ "/HoldShortApp/surface_ripple.xml")));

			} catch (Exception e) {

				if (e.getClass()
						.getCanonicalName()
						.equalsIgnoreCase(
								"com.mitre.holdshort.AirportXMLHandler.foundAirportInfoException")) {
				} else {
					Log.e(LOG_TAG, "AIRPORT XML PARSE ERROR", e);

				}
			}

			return airportXMLHandler.getAirport();
		}

		/**
		 * @param is
		 */
		private void readFile(InputStream is, File dir) {

			try {

				Log.d(LOG_TAG, "Inside READFILE");
				BufferedOutputStream buffer;
				buffer = new BufferedOutputStream(new FileOutputStream(dir));
				byte buff[] = new byte[1024];

				try {

					int i;
					for (long l = 0L; (i = is.read(buff)) != -1; l += i) {
						buffer.write(buff, 0, i);
					}

					is.close();
					buffer.close();

					Date dt = new Date(dir.lastModified());
					SimpleDateFormat dateFormat = (SimpleDateFormat) DateFormat
							.getTimeFormat(MainActivity.this);
					String dateString = dateFormat.format(dt);

					Log.d(LOG_TAG, dateString);

				} catch (IOException e) {
					e.printStackTrace();
				}

			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

		}

		protected void onPostExecute(String result) {
			airport = result;
			if (airport == null || airport.contains("_NS")) {
				showNotSupportedDialog(airport);
			} else {
				startMainActivity();
			}
			Log.i(LOG_TAG, String.valueOf((System.currentTimeMillis() - startTime) / 1000));
		}

	}

	private void showNotSupportedDialog(String airport) {
		final Dialog dialog = new Dialog(MainActivity.this);
		OnCancelListener notSupportedCancelListener = null;
		notSupportedCancelListener = new OnCancelListener() {

			@Override
			public void onCancel(DialogInterface dialog) {

				dialog.dismiss();
				finish();

			}

		};

		OnClickListener noAirportClickListener = new OnClickListener() {

			@Override
			public void onClick(View v) {

				switch (v.getId()) {

				case R.id.exit:
					dialog.dismiss();
					finish();
					break;
				case R.id.contactMitre:
					Log.d(LOG_TAG, "TEST");
					contactMITRE("RIPPLE App Support");
				case R.id.uploadData:
					AlertLogger al = new AlertLogger("999", MainActivity.this);
				default:
					return;

				}
			}

		};

		if (airport == null) {
			dialog.setOnCancelListener(notSupportedCancelListener);
			dialog.setContentView(R.layout.no_airport_found_dialog);
			dialog.setTitle("No Airport Found!");
			dialog.getWindow().setLayout(ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.WRAP_CONTENT);

			Button exit = (Button) dialog.findViewById(R.id.exit);
			Button contact = (Button) dialog.findViewById(R.id.contactMitre);
			Button uploadData = (Button) dialog.findViewById(R.id.uploadData);
			contact.setOnClickListener(noAirportClickListener);
			exit.setOnClickListener(noAirportClickListener);
			uploadData.setOnClickListener(noAirportClickListener);

			dialog.show();
		} else {
			dialog.setOnCancelListener(notSupportedCancelListener);
			dialog.setContentView(R.layout.airport_not_supported_dialog);
			dialog.setTitle("Airport " + (airport.split("_"))[0] + " Not Supported");
			dialog.getWindow().setLayout(ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.WRAP_CONTENT);
			Button exit = (Button) dialog.findViewById(R.id.exit);
			Button contact = (Button) dialog.findViewById(R.id.contactMitre);
			contact.setOnClickListener(noAirportClickListener);
			exit.setOnClickListener(noAirportClickListener);
			dialog.show();
		}

	}

	private void contactMITRE(String subject) {

		final Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);
		emailIntent.setType("plain/text");
		emailIntent.putExtra(android.content.Intent.EXTRA_EMAIL,
				new String[] { "ripple@mitre.org" });
		emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, subject);
		emailIntent.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
		startActivity(Intent.createChooser(emailIntent, "Send mail..."));
	}

	private OnClickListener speechBtnClickListener = new OnClickListener() {

		// TO DO:
		// Set up connection to speech recognition thread

		@Override
		public void onClick(View arg0) {

			speech = !speech;
			if (speech) {
				speechBtn.setImageResource(R.drawable.mic_on_32bit);
				// RECORD
			} else {
				speechBtn.setImageResource(R.drawable.mic_off_32bit);
				// STOP
			}

		}

	};
	private OnClickListener minimizeAlert = new OnClickListener() {

		@Override
		public void onClick(View v) {

			if (currentAlert != null) {

				miniAlert.setBackgroundDrawable(imageHelper.getRoundedCornerBitmap(
						BitmapFactory.decodeResource(getResources(), R.drawable.alert_mini), 10));
				switch (currentAlert) {
				case HOLD_SHORT:
					miniAlert.setText("Hold Short");
					break;
				case NO_CLEARANCE:
					miniAlert.setText("Hold Short");
					break;
				case WRONG_RUNWAY:
					miniAlert.setText("Wrong Runway");
					break;
				default:
					miniAlert.setText("Reminders Disabled");
					break;
				}
			} else {
				miniAlert.setText("Reminders Disabled");
				miniAlert
						.setBackgroundDrawable(imageHelper.getRoundedCornerBitmap(BitmapFactory
								.decodeResource(getResources(), R.drawable.disabled_mini), 10));
			}
			LayoutParams p = (LayoutParams) miniAlert.getLayoutParams();
			p.width = LayoutParams.FILL_PARENT;
			p.height = 50;
			miniAlert.setLayoutParams(p);
			miniAlert.setVisibility(TextView.VISIBLE);
			alertScreen.setVisibility(RelativeLayout.GONE);
		}

	};

	private OnClickListener maximizeAlert = new OnClickListener() {

		@Override
		public void onClick(View v) {

			miniAlert.setVisibility(TextView.GONE);
			alertScreen.setVisibility(RelativeLayout.VISIBLE);
		}
	};

	private OnClickListener depRwyListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			depRwyDialog = new DepRwyDialog(MainActivity.this);
			depRwyDialog.setContentView(R.layout.dep_rwy_picker);
			depRwyDialog.setCanceledOnTouchOutside(true);
			LinearLayout runwayHolder = (LinearLayout) depRwyDialog.findViewById(R.id.runwayHolder);
			depRwyDialog.setOnCancelListener(depRwyDialogCancelListener);
			TextView dialogText = (TextView) depRwyDialog.findViewById(R.id.depRwyDialogText);

			// Set-up Dialog Box

			int i = 0;
			for (RunwayZone rwy : rwyMgr.runways) {

				DepRunwayBar rwyBar = new DepRunwayBar(MainActivity.this);
				rwyBar.setHandler(depRwyDialog.mainHandler);
				runwayHolder.addView(rwyBar, runwayHolder.getChildCount(), new LayoutParams(
						LinearLayout.LayoutParams.WRAP_CONTENT, 45));

				rwyBar.setRunwayText(rwy.getName());
				rwyBar.setRwyId(i);

				if (depRunway != null) {
					depRwyDialog.setOldRunway(depRunway);
					depRwyDialog.setOldLoad(true);
					dialogText.setText("Departure runway set to " + depRunway);
					if (((String[]) rwyBar.getRunwayText().split("-"))[0].contentEquals(depRunway)) {
						rwyBar.setRunwayStatus(2);

					} else if (((String[]) rwyBar.getRunwayText().split("-"))[1]
							.contentEquals(depRunway)) {
						rwyBar.setRunwayStatus(1);
					}
				}

				i++;
			}

			depRwyDialog.show();

		}

	};
	private OnCancelListener depRwyDialogCancelListener = new OnCancelListener() {

		@Override
		public void onCancel(DialogInterface dialog) {

			LinearLayout runwayHolder = (LinearLayout) depRwyDialog.findViewById(R.id.runwayHolder);
			int children = runwayHolder.getChildCount();

			depRunway = null;

			for (int i = 0; i < children; i++) {

				DepRunwayBar child = (DepRunwayBar) runwayHolder.getChildAt(i);
				if (child.getRunwayStatus() == 1) {
					depRunway = child.getRunwayRightText();
				}
				if (child.getRunwayStatus() == 2) {
					depRunway = child.getRunwayLeftText();
				}
			}

			if (depRunway != null) {
				depRwyBtn.setText("DEPART " + depRunway);
				depRwyBtn.setBackgroundResource(R.drawable.new_thumb);
				depRwyBtn.setPadding(10, 5, 10, 5);
			} else {
				depRwyBtn.setText("Departure Rwy");
				depRwyBtn.setBackgroundResource(R.drawable.hatched_small_bg_layer);
				depRwyBtn.setPadding(10, 5, 10, 5);
			}

		}

	};

	private OnClickListener taxiPathListener = new OnClickListener() {

		@Override
		public void onClick(View v) {

			if (instructionArray != null) {
				DialogNoTitle dialog = new DialogNoTitle(MainActivity.this);
				dialog.setCanceledOnTouchOutside(true);
				dialog.setContentView(R.layout.taxi_path_dialog);
				WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
				lp.dimAmount = 0.0f;
				dialog.getWindow().setAttributes(lp);
				dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
				ListView list = (ListView) dialog.findViewById(R.id.instructionList);

				list.setAdapter(new TaxiInstructionAdapter(MainActivity.this,
						R.layout.list_item_small_text, instructionList));
				dialog.show();
			}
		}
	};

	private OnClickListener settingsMenuListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Intent settingsActivity = new Intent(getBaseContext(), Preferences.class);
			startActivity(settingsActivity);
		}

	};

	public void setUpRunways() {

		/*
		 * Set up RunwayBar Container
		 * 
		 * Basically, we'll loop through the Runway Manager list, create a new
		 * runway bar for each runway, attach it to the runway in the list and
		 * put it in the drawer
		 */

		// add top spacer

		for (int i = 0; i < rwyMgr.runways.size(); i++) {

			RunwayBar rwyBar = new RunwayBar(MainActivity.this);
			rwyMgr.runways.get(i).setRunwayBar(rwyBar);
			rwyBar.setRunwayText(rwyMgr.runways.get(i).getName());
			innerHolder.addView(rwyBar, LayoutParams.FILL_PARENT, 45);
			innerHolder.invalidate();
		}

	}

	public void displaySummaryInfo() {

		rwyMgr.updateHoldShortStatus();

		if (summaryIndex + 1 > rwyMgr.getRwyHoldShortSize()) {
			summaryIndex = 0;
		}

		if (rwyMgr.getRwyHoldShortSize() > 0) {
			Animation fadeIn = AnimationUtils.loadAnimation(this, android.R.anim.fade_in);
			fadeIn.setDuration(1000);
			summaryInfo.setAnimation(fadeIn);

			summary_index.setText((summaryIndex + 1) + " of " + rwyMgr.getRwyHoldShortSize());
			summary_thumb.setText(rwyMgr.rwyHoldShort.get(summaryIndex).getRunwayText());
			summaryInfo.setVisibility(RelativeLayout.VISIBLE);

		} else {
			summaryInfo.setVisibility(RelativeLayout.INVISIBLE);
		}

	}

	private void hideSummaryInfo() {

		summaryInfo.setVisibility(RelativeLayout.INVISIBLE);
	}

	private OnClickListener openCloseListener = new OnClickListener() {

		public void onClick(View v) {

			slidingPanel.toggle();

		}
	};

	private OnClickListener taxiBtnListener = new OnClickListener() {

		public void onClick(View v) {

			String runways = null;

			for (int i = 0; i < rwyMgr.runways.size(); i++) {
				if (i == 0) {
					runways = rwyMgr.runways.get(i).getName();
				} else {
					runways = runways + "," + rwyMgr.runways.get(i).getName();
				}
			}

			Intent i = new Intent(MainActivity.this, TaxiClearanceActivity.class);
			i.putExtra("com.mitre.holdshort.RUNWAYS", runways);

			if (depRunway != null) {
				i.putExtra("com.mitre.holdshort.TAXI_RUNWAY", depRunway);
			}

			if (instructionArray != null) {
				i.putExtra("com.mitre.holdshort.TAXI_PATH", instructionArray);
			}

			startActivityForResult(i, TAXI_CLEARANCE);
		}
	};

	private Handler handler = new Handler() {

		@Override
		public void handleMessage(Message msg) {

			switch (msg.what) {
			case 1:
				displaySummaryInfo();
				break;
			case 2:
				hideSummaryInfo();
				break;
			default:
				break;
			}

		}

	};

	private void checkForAlert(Location loc) {

		// Create a point for our location
		// just need lat & lon
		myPosition = new Point();
		myPosition.setLatitude(loc.getLatitude());
		myPosition.setLongitude(loc.getLongitude());

		// Update current location info
		currentLat = myPosition.getLatitude();
		currentLon = myPosition.getLongitude();

		// Heading, Altitude, Speed

		// Check if bearing is available
		if (loc.hasBearing()) {
			currentHdg = loc.getBearing();
		}

		// Check if altitude is available & convert to feet
		if (loc.hasAltitude()) {
			currentAlt = loc.getAltitude() * M_TO_FEET;
		}

		// Get speed and convert to knots
		currentSpd = (float) (loc.getSpeed() * MS_TO_KNOTS);

		// Only alert below 1000 feet
		if (currentAlt < 1000) {

			/*
			 * Get proximity information:
			 * 
			 * proximityAlerting() returns an Alert
			 */

			Alert alert = proximityAlerting();

			if (alert == null) {

				// If no alert (i.e. null) then
				// clear the logger and clear alert from screen
				alertLogger.clearAlert(loc, AlertLogger.AlertEndType.CLEARED_ALERT);
				showAlert(null, null);

			} else {

				// update the currentAlert variable
				currentAlert = alert.getAlertType();

				if (!alert.isPersistent()) {

					// If this is a new alert then
					// Start a record for this alert in the AlertLogger and
					// Show/Play alert
					alertLogger.startAlert(loc, alert.getAlertType(), alert.getRunway(), airport);
					showAlert(alert.getAlertType(), alert.getRunway());

					if (mp.isPlaying()) {
						mp.stop();
						mp.reset();
						generatePlaybackArray(alert.getAlertType(), alert.getRunway());
					} else {
						generatePlaybackArray(alert.getAlertType(), alert.getRunway());
					}
				}
			}
		}
	}

	private void generatePlaybackArray(Alert.AlertType alertType, String alertRunway) {

		/*
		 * sounds is a List to help figure out which sounds to play in what
		 * order.
		 * 
		 * First: We'll clear the list out and reset the counter (soundNum) to 0
		 * 
		 * Second: We'll grab the alert type and parse the runway adding each
		 * element as a new item to the list.
		 */

		sounds.clear();
		soundNum = 0;

		if (alertType == Alert.AlertType.HOLD_SHORT) {
			sounds.add("HOLD_SHORT");
		}
		if (alertType == Alert.AlertType.CROSSING) {
			sounds.add("CROSSING");
		}
		if (alertType == Alert.AlertType.NO_CLEARANCE) {
			sounds.add("NO_CLEARANCE");
		}
		if (alertType == Alert.AlertType.WRONG_RUNWAY) {
			sounds.add("WRONG_RUNWAY");
		}

		alertRunway = alertRunway.substring(0, alertRunway.indexOf("-"));

		for (int i = 0; i < alertRunway.length(); i++) {
			sounds.add(String.valueOf(alertRunway.charAt(i)));
		}

		playAlert();

	}

	private void playAlert() {

		// Check if the user wants aural alerts
		if (auralAlerts) {

			// Check and make sure counter is less than the size of the list
			// If not, clear sounds and reset counter
			if (soundNum < sounds.size()) {
				try {
					// Go through each of the sounds and see if the current
					// sound matches
					// If it does then set the dataSource for the player and
					// play
					// When the sound is done playing the finish callback
					// increments soundNum
					// and sends it back to this method.

					if (sounds.get(soundNum).equalsIgnoreCase("HOLD_SHORT")) {

						AssetFileDescriptor afd = getAssets().openFd("holdShortOfRunway.mp3");
						mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
								afd.getLength());
						mp.prepare();
						mp.start();
					}

					if (sounds.get(soundNum).equalsIgnoreCase("CROSSING")) {
						AssetFileDescriptor afd = getAssets().openFd("crossingRunway.mp3");
						mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
								afd.getLength());
						mp.prepare();
						mp.start();
					}
					if (sounds.get(soundNum).equalsIgnoreCase("NO_CLEARANCE")) {
						AssetFileDescriptor afd = getAssets().openFd(
								"holdShortNoClearanceForRunway.mp3");
						mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
								afd.getLength());
						mp.prepare();
						mp.start();
					}

					if (sounds.get(soundNum).equalsIgnoreCase("WRONG_RUNWAY")) {

						AssetFileDescriptor afd = getAssets().openFd("noTakeoffClearance.mp3");
						mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
								afd.getLength());
						mp.prepare();
						mp.start();
					}

					if (settings.getBoolean("announceRWY", true)) {

						if (sounds.get(soundNum).equalsIgnoreCase("1")) {
							AssetFileDescriptor afd = getAssets().openFd("1.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("2")) {
							AssetFileDescriptor afd = getAssets().openFd("2.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("3")) {
							AssetFileDescriptor afd = getAssets().openFd("3.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("4")) {
							AssetFileDescriptor afd = getAssets().openFd("4.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("5")) {
							AssetFileDescriptor afd = getAssets().openFd("5.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("6")) {
							AssetFileDescriptor afd = getAssets().openFd("6.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("7")) {
							AssetFileDescriptor afd = getAssets().openFd("7.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("8")) {
							AssetFileDescriptor afd = getAssets().openFd("8.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("9")) {
							AssetFileDescriptor afd = getAssets().openFd("9.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("0")) {
							AssetFileDescriptor afd = getAssets().openFd("0.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("L")) {
							AssetFileDescriptor afd = getAssets().openFd("left.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("C")) {
							AssetFileDescriptor afd = getAssets().openFd("center.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
						if (sounds.get(soundNum).equalsIgnoreCase("R")) {
							AssetFileDescriptor afd = getAssets().openFd("right.mp3");
							mp.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(),
									afd.getLength());
							mp.prepare();
							mp.start();
						}
					}
				} catch (IOException e) {

				}

			} else {
				sounds.clear();
				soundNum = 0;
			}
		}
	}

	private OnCompletionListener alertPlaybackListener = new OnCompletionListener() {

		@Override
		public void onCompletion(MediaPlayer mp) {
			mp.reset();
			soundNum = soundNum + 1;
			playAlert();
		}

	};

	public Alert proximityAlerting() {

		// The alertManager does the arbitrating of the alerts.
		// First we'll clear the old alerts and look for a new one

		alertManager.clearPastAlerts();

		// Now, loop through each runway in the Runway Manager
		for (RunwayZone rwy : rwyMgr.runways) {

			// Get Runway headings for orientation check
			double runwayOrientationBC = rwy.heading1;
			double runwayOrientationDA = rwy.heading2;

			// List of lat/lon points defining runway boundary
			List<Point> borders = rwy.getPolyBounds();

			/*
			 * FIRST PASS: Check if current position is inside runway zone
			 */

			Boolean inside = inPoly(borders, borders.size(), myPosition.getLatitude(),
					myPosition.getLongitude());

			if (inside) {

				// Check and see if departure runway is set
				// If is we'll look to suppress alerts or issue wrong runway
				// alert

				if (depRunway != null) {

					// check and see if this runway is our departure runway
					if (rwy.getName().indexOf(depRunway) != -1
							&& (Math.abs(computeTrackAngleError(currentHdg, runwayOrientationBC)
									* (180 / Math.PI)) < 20 || Math.abs(computeTrackAngleError(
									currentHdg, runwayOrientationDA) * (180 / Math.PI)) < 20)) {

						// Let the alertManager know we're lined up on our
						// departure runway and move to the next runway in the
						// list
						alertManager.setPositionAndHold(true);
						continue;
					} else if (currentSpd > 45
							&& (Math.abs(computeTrackAngleError(currentHdg, runwayOrientationBC)
									* (180 / Math.PI)) < 20 || Math.abs(computeTrackAngleError(
									currentHdg, runwayOrientationDA) * (180 / Math.PI)) < 20)) {

						// We're not on our runway so we're not "in position"
						alertManager.setPositionAndHold(false);

						// WRONG RUNWAY ALERT:
						// Check if alert has already been issued
						if (rwy.getAlert() == Alert.AlertType.WRONG_RUNWAY) {
							// Add to Alert Manager Queue & move on
							Alert alert = new Alert(Alert.AlertType.WRONG_RUNWAY, true, true,
									rwy.getName());
							alertManager.addAlert(alert);
							continue;
						} else {
							// Add to Alert Manager Queue & move on
							Alert alert = new Alert(Alert.AlertType.WRONG_RUNWAY, false, true,
									rwy.getName());
							alertManager.addAlert(alert);
							continue;
						}

					}
				}

				// If we got here we're not "lined-up" with the runway
				// Let's check for other alerts regardless of speed

				// Crossing Alert
				if (rwy.getRunwayBar().isClearedSet()) {
					if (rwy.getAlert() == Alert.AlertType.CROSSING) {
						// Add to Alert Manager Queue & move on
						Alert alert = new Alert(Alert.AlertType.CROSSING, true, true, rwy.getName());
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					} else {
						// Add to Alert Manager Queue & move on
						Alert alert = new Alert(Alert.AlertType.CROSSING, false, true,
								rwy.getName());
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					}
				}

				// Hold Short Alert
				if (rwy.getRunwayBar().isHoldSet()) {
					// This prevents "new" alerts from popping up
					if (rwy.getAlert() == Alert.AlertType.HOLD_SHORT) {
						// Add to Alert Manager Queue & move on
						Alert alert = new Alert(Alert.AlertType.HOLD_SHORT, true, true,
								rwy.getName());
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					}
				}

				// No Clearance Alert
				if (rwy.getRunwayBar().isNotSet()) {
					// This prevents "new" alerts from popping up
					if (rwy.getAlert() == Alert.AlertType.NO_CLEARANCE) {
						// Add to Alert Manager Queue & move on
						Alert alert = new Alert(Alert.AlertType.NO_CLEARANCE, true, true,
								rwy.getName());
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					}
				}

			}

			/*
			 * SECOND PASS: Current position is not inside runway zone. Check if
			 * we are going to intersect runway zone within threshold.
			 */

			// Get future position based on look-ahead threshold and current
			// heading
			Point futurePoint = futurePoint(myPosition.getLatitude(), myPosition.getLongitude());
			// For each runway border, check if intersection exists

			int j = borders.size() - 1;
			Point intersection = null;
			for (int i = 0; i < borders.size(); i++) {

				intersection = intersection(myPosition, futurePoint, borders.get(j), borders.get(i));

				if (intersection != null) {
					break;
				} else {
					j = i;
				}
			}

			if (intersection != null) {

				alertManager.setPositionAndHold(false);
				if (rwy.getRunwayBar().isHoldSet()) // set to hold short
				{

					// check if alert already has been issued
					if (rwy.getAlert() == Alert.AlertType.HOLD_SHORT) {
						Alert alert = new Alert(Alert.AlertType.HOLD_SHORT, true, false,
								rwy.getName());
						// Add to Alert Manager Queue & move on
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					}

					Alert alert = new Alert(Alert.AlertType.HOLD_SHORT, false, false, rwy.getName());
					// Add to Alert Manager Queue & move on
					// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
					// alert.getRunway() + " -- "
					// + alert.getAlertType().name() + " --- " +
					// alert.isInside());
					alertManager.addAlert(alert);
					continue;
				}

				else if (rwy.getRunwayBar().isNotSet()) // not
														// set
				{
					// check to see if an approaching runway instruction
					// has already been issued
					if (rwy.getAlert() == Alert.AlertType.NO_CLEARANCE) {
						Alert alert = new Alert(Alert.AlertType.NO_CLEARANCE, true, false,
								rwy.getName());
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						alertManager.addAlert(alert);
						continue;
					}

					Alert alert = new Alert(Alert.AlertType.NO_CLEARANCE, false, false,
							rwy.getName());
					// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
					// alert.getRunway() + " -- "
					// + alert.getAlertType().name() + " --- " +
					// alert.isInside());
					alertManager.addAlert(alert);
					continue;
				}

				else if (rwy.getRunwayBar().isClearedSet()) // not
															// set
				{
					// check to see if an approaching runway instruction
					// has already been issued
					if (rwy.getAlert() == Alert.AlertType.CROSSING) {
						Alert alert = new Alert(Alert.AlertType.CROSSING, true, false,
								rwy.getName());
						alertManager.addAlert(alert);
						// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
						// alert.getRunway() + " -- "
						// + alert.getAlertType().name() + " --- " +
						// alert.isInside());
						continue;
					}

					Alert alert = new Alert(Alert.AlertType.CROSSING, false, false, rwy.getName());
					// Log.d(MainActivity.LOG_TAG, "Adding alert: " +
					// alert.getRunway() + " -- "
					// + alert.getAlertType().name() + " --- " +
					// alert.isInside());
					alertManager.addAlert(alert);
					continue;
				}
			}

		}

		// getAlertToShow() is where the arbitration happens
		// See AlertManager for more details
		Alert alertToShow = alertManager.getAlertToShow();

		if (alertToShow != null) {
			// Log.d(LOG_TAG, alertToShow.getRunway() + " -- " +
			// alertToShow.getAlertType().name());
		}
		return alertToShow;
	}

	public boolean inPoly(List<Point> polybounds, int polysides, double lat, double lon) {

		boolean inside = false;
		int j = polysides - 1;

		for (int i = 0; i < polysides; i++) {

			Double LATi = polybounds.get(i).getLatitude();
			Double LONi = polybounds.get(i).getLongitude();
			Double LATj = polybounds.get(j).getLatitude();
			Double LONj = polybounds.get(j).getLongitude();
			Double LAT = lat;
			Double LON = lon;

			if ((LONi < LON && LONj >= LON) || (LONj < LON && LONi >= LON)) {

				if (LATi + (LON - LONi) / (LONj - LONi) * (LATj - LATi) < LAT) {
					inside = !inside;
				}
			}
			j = i;
		}

		return inside;
	}

	public Point intersection(Point pMe, Point pFuture, Point pOne, Point pTwo) {

		double A1, B1, C1, A2, B2, C2;
		A1 = pFuture.getLongitude() - pMe.getLongitude();
		B1 = pMe.getLatitude() - pFuture.getLatitude();
		C1 = A1 * pMe.getLatitude() + B1 * pMe.getLongitude();

		A2 = pTwo.getLongitude() - pOne.getLongitude();
		B2 = pOne.getLatitude() - pTwo.getLatitude();
		C2 = A2 * pOne.getLatitude() + B2 * pOne.getLongitude();

		double det = A1 * B2 - A2 * B1;
		if (det == 0) {
			return null;
		} else {

			double x = (B2 * C1 - B1 * C2) / det;
			double y = (A1 * C2 - A2 * C1) / det;

			if (Math.min(pOne.getLatitude(), pTwo.getLatitude()) <= x
					&& x <= Math.max(pOne.getLatitude(), pTwo.getLatitude())
					&& Math.min(pOne.getLongitude(), pTwo.getLongitude()) <= y
					&& y <= Math.max(pOne.getLongitude(), pTwo.getLongitude())
					&& Math.min(pMe.getLatitude(), pFuture.getLatitude()) <= x
					&& x <= Math.max(pMe.getLatitude(), pFuture.getLatitude())
					&& Math.min(pMe.getLongitude(), pFuture.getLongitude()) <= y
					&& y <= Math.max(pMe.getLongitude(), pFuture.getLongitude())) {

				return new Point(x, y);
			} else {

				return null;
			}

		}

	}

	public Point futurePoint(Double lat, Double lon) {

		// Convert old lat/long to radians
		double oldLat = lat * Math.PI / 180;
		double oldLon = lon * Math.PI / 180;

		/*
		 * Get distance (in radians) based on current speed and Threshold
		 * Distance = Speed * Time Speed is in knots (nm/h) Threshold is in
		 * seconds so it will need to be converted into hours (divide by 3600).
		 */

		double distance = (currentSpd * (threshold / 3600)) * (Math.PI / (180 * 60));

		// Convert current heading to radians
		double radial = (360 - currentHdg) * (Math.PI / 180);

		/*
		 * Get new lat/lon using formula from
		 * http://williams.best.vwh.net/avform.htm
		 */

		double newLat = Math.asin(Math.sin(oldLat) * Math.cos(distance) + Math.cos(oldLat)
				* Math.sin(distance) * Math.cos(radial));

		double newLon;
		if (Math.cos(newLat) == 0) {
			newLon = oldLon; // endpoint a pole
		} else {
			double y = oldLon - Math.asin(Math.sin(radial) * Math.sin(distance) / Math.cos(newLat))
					+ Math.PI;
			double x = 2 * Math.PI;
			newLon = (y - x * Math.floor(y / x)) - Math.PI;
		}

		// Convert new lat/lon back to degrees
		newLat = newLat * 180 / Math.PI;
		newLon = newLon * 180 / Math.PI;

		// Create new point
		Point futurePoint = new Point(newLat, newLon);

		// Return futurePoint point
		return futurePoint;
	}

	public double computeTrackAngleError(float currentHdg2, Double bearingTwo) {
		if (bearingTwo < 0) {
			bearingTwo = 360 + bearingTwo; // (plus because bearing is negative)
		}

		Double TKE = (currentHdg2 - bearingTwo);

		if (TKE > 180) {
			TKE = TKE + 360;
		}

		else if (TKE < -180) {
			TKE = TKE + 360;
		}

		TKE = TKE * Math.PI / 180; // converts the value to radians

		return (TKE);
	}

	public double distanceBetweenTwoPoints(Point pointA, Point pointA2) {

		double lat1 = pointA.getLatitude() * Math.PI / 180;
		double lon1 = pointA.getLongitude() * Math.PI / 180;
		double lat2 = pointA2.getLatitude() * Math.PI / 180;
		double lon2 = pointA2.getLongitude() * Math.PI / 180;

		return (Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2)
				* Math.cos(lon2 - lon1)));
	}

	public double bearingBetweenTwoPoints(Point loc1, Point loc2) {
		double lat1 = loc1.getLatitude() * Math.PI / 180;
		double lon1 = loc1.getLongitude() * Math.PI / 180;
		double lat2 = loc2.getLatitude() * Math.PI / 180;
		double lon2 = loc2.getLongitude() * Math.PI / 180;
		double dLon = lon2 - lon1;

		double y = Math.sin(dLon) * Math.cos(lat2);
		double x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2)
				* Math.cos(dLon);

		return (Math.atan2(y, x)); // bearing in radians

	}

	public void processPathArray(String[] instructionArray2) {

		instructionList.clear();
		String taxiHint = "";
		for (int i = 0; i < instructionArray2.length; i++) {

			String instruction = instructionArray2[i];
			instructionList.add(instruction);

			if (instruction.contains("Hold Short")) {

				int startRWY = instruction.indexOf("RWY");
				int startRwyName = instruction.indexOf(" ", startRWY) + 1;
				int endRwyName = instruction.indexOf(" ", startRwyName);

				if (endRwyName == -1) {
					endRwyName = instruction.length();
				}

				String runwayName = instruction.substring(startRwyName, endRwyName);

				for (RunwayZone rwy : rwyMgr.runways) {
					if (rwy.getName().equalsIgnoreCase(runwayName)
							&& !rwy.getRunwayBar().isManual()) {
						rwy.getRunwayBar().setRunwayStatus(1);
						rwy.getRunwayBar().setThumbBounds(1);
					}
				}

			}

			if (instruction.contains("Cross")) {

				int startRWY = instruction.indexOf("RWY");
				int startRwyName = instruction.indexOf(" ", startRWY) + 1;
				int endRwyName = instruction.indexOf(" ", startRwyName);

				if (endRwyName == -1) {
					endRwyName = instruction.length();
				}

				String runwayName = instruction.substring(startRwyName, endRwyName);

				for (RunwayZone rwy : rwyMgr.runways) {
					if (rwy.getName().equalsIgnoreCase(runwayName)
							&& !rwy.getRunwayBar().isManual()) {
						rwy.getRunwayBar().setRunwayStatus(2);
						rwy.getRunwayBar().setThumbBounds(2);
					}
				}

			}

			taxiHint = taxiHint + (i + 1) + ": " + instructionArray2[i] + "\n";
		}
		taxiClearance.setText(taxiHint);
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// See which child activity is calling us back.
		switch (requestCode) {
		case TAXI_CLEARANCE:

			// Clear Out Taxi Paths
			instructionList.clear();
			taxiClearance.setText("");
			instructionArray = null;

			// Clear bars
			for (RunwayZone rwy : rwyMgr.runways) {
				if (!(rwy.getRunwayBar().isManual())) {
					rwy.getRunwayBar().setRunwayStatus(0);
					rwy.getRunwayBar().setThumbBounds(0);
				}
			}

			// This is the standard resultCode that is sent back if the
			// activity crashed or didn't doesn't supply an explicit result.
			if (resultCode == RESULT_CANCELED) {

			} else {

				if (data.hasExtra("com.mitre.holdshort.TAXI_RUNWAY")) {
					depRunway = data.getExtras().getString("com.mitre.holdshort.TAXI_RUNWAY");
					depRwyBtn.setText("Depart RWY "
							+ data.getExtras().getString("com.mitre.holdshort.TAXI_RUNWAY"));
					depRwyBtn.setBackgroundResource(R.drawable.new_thumb);
					depRwyBtn.setPadding(10, 5, 10, 5);
				}

				if (data.hasExtra("com.mitre.holdshort.TAXI_PATH")) {
					instructionArray = data.getExtras().getStringArray(
							"com.mitre.holdshort.TAXI_PATH");
					processPathArray(instructionArray);
				}
			}

		default:
			break;
		}
	}

	@Override
	protected void onDestroy() {

		if (currentAlert != null) {
			alertLogger.clearAlert(currentLocation, AlertLogger.AlertEndType.SYSTEM_EXIT);
		}

		super.onDestroy();
	}

	@Override
	protected void onStop() {

		super.onStop();
	}

	@Override
	protected void onResume() {

		if (!allSetUp && waiverAccept) {
			checkGPSSettings();
		}

		auralAlerts = settings.getBoolean("auralAlerts", true);
		announceRWY = settings.getBoolean("announceRWY", true);
		super.onResume();

	}

	class summaryGester extends SimpleOnGestureListener {

		private static final int SWIPE_MIN_DISTANCE = 100;
		private static final int SWIPE_MAX_OFF_PATH = 250;
		private static final int SWIPE_THRESHOLD_VELOCITY = 50;

		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {

			RunwayBar currentRwy;

			try {
				if (Math.abs(e1.getY() - e2.getY()) > SWIPE_MAX_OFF_PATH)
					return false;
				// right to left swipe
				if (e1.getX() - e2.getX() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {

					if (rwyMgr.rwyHoldShort.size() == (summaryIndex + 1)) {
						summaryIndex = 0;
					} else {
						summaryIndex = summaryIndex + 1;
					}

					currentRwy = rwyMgr.rwyHoldShort.get(summaryIndex);
					summary_thumb.setText(currentRwy.getRunwayText());
					summary_index.setText((summaryIndex + 1) + " of "
							+ rwyMgr.getRwyHoldShortSize());

				} else if (e2.getX() - e1.getX() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {

					if (summaryIndex == 0) {
						summaryIndex = rwyMgr.getRwyHoldShortSize() - 1;
					} else {
						summaryIndex = summaryIndex - 1;
					}

					currentRwy = rwyMgr.rwyHoldShort.get(summaryIndex);
					summary_thumb.setText(currentRwy.getRunwayText());
					summary_index.setText((summaryIndex + 1) + " of "
							+ rwyMgr.getRwyHoldShortSize());
				}
			} catch (Exception e) {
				// nothing
			}
			return false;
		}
	}

	private OnTouchListener summaryTouchListener = new OnTouchListener() {

		@Override
		public boolean onTouch(View v, MotionEvent event) {

			if (summaryInfo.getVisibility() == View.VISIBLE) {
				if (summaryGestureDetector.onTouchEvent(event)) {
				}
			}

			return true;
		}

	};

}
