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

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Picture;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader.TileMode;
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationProvider;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.OnDoubleTapListener;
import android.view.GestureDetector.OnGestureListener;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.widget.ImageView;
import android.widget.Scroller;
import android.widget.Toast;

import com.mitre.holdshort.AirportPlateView.NavPoint;

import java.lang.Math.*;
import java.lang.reflect.Array;

public class AirportPlateView extends View implements OnGestureListener, OnDoubleTapListener {


	private int WIDTH = 1000;
	private int HEIGHT = 1500;
	private static final float MAX_ZOOM = 2;

	private static final int MSG_ZOOMING_IN = 1;
	private static final int MSG_ZOOMING_OUT = 2;

	private float mX;
	private float mY;
	private Scroller mScroller;
	private GestureDetector mGestureDetector;
	private float mScale;
	private Bitmap mAndroid;
	private Bitmap mNav;
	private List<Point> refPointsLatLon;
	private List<XYPoint> refPointsXY;
	private NavPoint navLocation;
	private double pixelScaleFactor;
	private double bearingOffset;
	private int originX = 0;
	private int originY = 0;
	private int newWIDTH = 0;
	private int newHEIGHT = 0;
	private ScaleGestureDetector mScaleDetector;
	private Bitmap rotatedMap;
	private boolean initialAdjustment = false;
	private float scrollX1;
	private float scrollX2;
	private float scrollY1;
	private float scrollY2;
	private boolean showOwnship = true;
	private boolean navOffScreen;
	private ImageView navControl;

	public AirportPlateView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mScroller = new Scroller(context);
		mGestureDetector = new GestureDetector(this);
		// mGestureDetector.setIsLongpressEnabled(false);

		mScaleDetector = new ScaleGestureDetector(context, new ScaleListener());
		refPointsXY = new ArrayList<XYPoint>();
		refPointsLatLon = new ArrayList<Point>();
		mNav = BitmapFactory.decodeResource(getResources(), R.drawable.nav2);
		mAndroid = BitmapFactory.decodeResource(getResources(), R.drawable.ksfo);
		mScale = 1;

	}

	public void geoReference(Point latLon1, Point latLon2, XYPoint xy1, XYPoint xy2) {

		Log.d("RIPPLE", "GEO-REFERENCING");
		// Add first points
		addLatLonRefPoint(latLon1);
		addXYRefPoint(xy1);

		// Add second points
		addLatLonRefPoint(latLon2);
		addXYRefPoint(xy2);

		double distance = distanceBetweenTwoPoints(refPointsLatLon.get(0), refPointsLatLon.get(1));
		Log.d("RIPPLE", "Distance:" + distance);
		double pixelDistance = distanceBetweenTwoXYPoints(refPointsXY.get(0), refPointsXY.get(1));
		Log.d("RIPPLE", "Pixel Distance:" + pixelDistance);
		// number of pixels per nm
		pixelScaleFactor = pixelDistance / distance;
		Log.d("RIPPLE", "Scale:" + pixelScaleFactor);

		// Let's figure out if the chart is rotated other than north up
		double bearing = (Math.toDegrees(bearingBetweenTwoPoints(refPointsLatLon.get(0),
				refPointsLatLon.get(1))) + 360) % 360;
		Log.d("RIPPLE", "Bearing:" + bearing);
		double pixelBearing = (Math.toDegrees(bearingBetweenTwoXYPoints(refPointsXY.get(0),
				refPointsXY.get(1))) + 90 + 360) % 360;
		Log.d("RIPPLE", "Pixel Bearing:" + pixelBearing);
		bearingOffset = pixelBearing - bearing;
		Log.d("RIPPLE", "Bearing Offset:" + bearingOffset);

		// Let's set up any rotation of the plate
		// and adjust our origin
		adjustForRotation();
	}

	private void addXYRefPoint(XYPoint xyPoint) {
		refPointsXY.add(xyPoint);
	}

	private void addLatLonRefPoint(Point latLonPoint) {
		refPointsLatLon.add(latLonPoint);
	}

	private double distanceBetweenTwoXYPoints(XYPoint point1, XYPoint point2) {

		double diffX = point2.getX() - point1.getX();
		double diffY = point2.getY() - point1.getY();

		return Math.sqrt(diffX * diffX + diffY * diffY);

	}

	private double distanceBetweenTwoPoints(Point pointA, Point pointA2) {

		double lat1 = pointA.getLatitude() * Math.PI / 180;
		double lon1 = pointA.getLongitude() * Math.PI / 180;
		double lat2 = pointA2.getLatitude() * Math.PI / 180;
		double lon2 = pointA2.getLongitude() * Math.PI / 180;

		return (Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2)
				* Math.cos(lon2 - lon1)))
				* MainActivity.radius;
	}

	private double bearingBetweenTwoPoints(Point loc1, Point loc2) {
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

	private double bearingBetweenTwoXYPoints(XYPoint point1, XYPoint point2) {

		double diffX = point2.getX() - point1.getX();
		double diffY = point2.getY() - point1.getY();

		return Math.atan2(diffY, diffX);
	}

	class NavPoint {

		private int x;
		private int y;
		private double bearing;

		public void setX(int x) {
			this.x = x;
		}

		public int getX() {
			return x;
		}

		public void setY(int y) {
			this.y = y;
		}

		public int getY() {
			return y;
		}

		public void setBearing(double bearing) {
			this.bearing = bearing;
		}

		public double getBearing() {
			return bearing;
		}

	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		mScaleDetector.onTouchEvent(event);
		return mGestureDetector.onTouchEvent(event);
	}

	@Override
	protected void onDraw(Canvas canvas) {

		canvas.save();

		if (bearingOffset != 0 && !initialAdjustment) {
			adjustForRotation();
			initialAdjustment = true;
		}

		// Log.d("RIPPLE", "Canvas: W:" + canvas.getWidth() + " H:" +
		// canvas.getHeight());
		if (mScroller.computeScrollOffset()) {
			mX = mScroller.getCurrX();
			mY = mScroller.getCurrY();
			invalidate();
		}
		canvas.drawColor(Color.rgb(255, 255, 255));

		canvas.scale(mScale, mScale);
		Paint paint = new Paint();
		paint.setFilterBitmap(true);
		float dx = mX - (getWidth() / mScale) * (mX / WIDTH);
		float dy = mY - (getHeight() / mScale) * (mY / HEIGHT);

		scrollX1 = (dx == 0) ? (0) : (0 - dx);
		scrollX2 = scrollX1 + getWidth() / mScale;
		scrollY1 = (dx == 0) ? (0) : (0 - dx);
		scrollY2 = scrollY1 + getWidth() / mScale;
		if (showOwnship) {
			float[] newTranslate = adjustForOffscreen(dx, dy);
			mX = newTranslate[0] / (1 - (getWidth() / (mScale * WIDTH)));
			dx = newTranslate[0];
			dy = newTranslate[1];
			navOffScreen = false;
		} else {
			navOffScreen = checkForOffScreen();
		}

		canvas.translate(dx, dy);
		canvas.rotate((float) (-1 * bearingOffset), 0, 0);
		canvas.translate(originX, originY);

		Matrix m2 = new Matrix();
		canvas.drawBitmap(mAndroid, m2, paint);

		Matrix mtx = new Matrix();
		mtx.setRotate((float) ((navLocation.getBearing()) + bearingOffset), mNav.getWidth() / 2,
				mNav.getHeight() / 2);
		Bitmap copy = Bitmap.createBitmap(mNav, 0, 0, mNav.getWidth(), mNav.getHeight(), mtx, true);

		canvas.drawBitmap(copy, navLocation.getX() - (copy.getScaledWidth(canvas) / 2),
				navLocation.getY() - (copy.getScaledHeight(canvas) / 2), null);
		canvas.rotate((float) (bearingOffset), canvas.getWidth() / 2, canvas.getHeight() / 2);
		canvas.restore();

		if (navOffScreen && mapUnlocked) {
			showNavControls(true);
		} else {
			showNavControls(false);

		}

		// Log.d("RIPPLE", "mX:" + mX + " mY:" + mY);
	}

	private void showNavControls(boolean show) {

		if (show) {
			navControl.setVisibility(View.VISIBLE);
		} else {		
			navControl.setVisibility(View.INVISIBLE);
		}

	}



	private boolean checkForOffScreen() {

		int navX = WIDTH - navLocation.getY();

		if (navX < scrollX1 || scrollX2 < navX) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 
	 */
	private float[] adjustForOffscreen(float dx, float dy) {

		float newX = dx;
		int navX = WIDTH - navLocation.getY();

		if (navX < scrollX1 || scrollX2 < navX) {

			if (navX < scrollX1) {
				newX = dx + (scrollX1 - (navX)) + Math.max(mNav.getHeight(), mNav.getWidth()) + 20;
			} else {
				newX = dx - ((navX) - (scrollX2 - 20));
			}

		}
		float[] newValues = { newX, dy };
		return newValues;

	}

	/**
	 * 
	 */
	private void adjustForRotation() {

		Matrix mtx = new Matrix();
		mtx.setRotate((float) (-1 * bearingOffset), mAndroid.getWidth() / 2,
				mAndroid.getHeight() / 2);
		rotatedMap = Bitmap.createBitmap(mAndroid, 0, 0, mAndroid.getWidth(), mAndroid.getHeight(),
				mtx, true);

		Log.d("RIPPLE",
				"Rotated Image: W:" + rotatedMap.getWidth() + " H:" + rotatedMap.getHeight());
		Log.d("RIPPLE", "BRG OFFSET(DOUBLE): " + bearingOffset);
		Log.d("RIPPLE", "BRG OFFSET(INT): " + (int) bearingOffset);

		if ((int) bearingOffset == -270) {
			Log.d("RIPPLE", "CASE -270");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = -HEIGHT;
			originY = 0;
		} else if ((int) bearingOffset == -180) {
			Log.d("RIPPLE", "CASE -180");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = -WIDTH;
			originY = -HEIGHT;
		} else if ((int) bearingOffset == -90) {
			Log.d("RIPPLE", "CASE -90");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = 0;
			originY = -WIDTH;
		} else if ((int) bearingOffset == 90) {
			Log.d("RIPPLE", "CASE 90");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = -HEIGHT;
			originY = 0;
		} else if ((int) bearingOffset == 180) {
			Log.d("RIPPLE", "CASE 180");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = -WIDTH;
			originY = -HEIGHT;
		} else if ((int) bearingOffset == 270) {
			Log.d("RIPPLE", "CASE 270");
			WIDTH = rotatedMap.getWidth();
			HEIGHT = rotatedMap.getHeight();
			originX = 0;
			originY = -WIDTH;
		} else {
			Log.d("RIPPLE", "CASE DEFAULT");
			newWIDTH = (int) Math.sqrt((mAndroid.getWidth() * mAndroid.getWidth())
					+ (mAndroid.getHeight() * mAndroid.getHeight()));
			newHEIGHT = (int) Math.sqrt((mAndroid.getWidth() * mAndroid.getWidth())
					+ (mAndroid.getHeight() * mAndroid.getHeight()));

			WIDTH = mAndroid.getWidth();
			HEIGHT = mAndroid.getHeight();
		}

	}

	public boolean onDown(MotionEvent e) {
		return true;
	}

	public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
		// Log.d(TAG, "onFling ");

		// you can control your fling speed by adjusting velocities
		velocityX *= 0.10;
		velocityY *= 0.10;

		mScroller
				.fling((int) mX, (int) mY, (int) velocityX, (int) velocityY, -WIDTH, 0, -HEIGHT, 0);
		invalidate();
		return true;
	}

	public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {

		showOwnship = false;
		if (mapUnlocked) {
			if (rotatedMap != null) {
				// Check if horizontal scroll is needed
				if (rotatedMap.getWidth() * mScale > this.getWidth()) {
					mX -= distanceX / mScale;
					mX = Math.max(-WIDTH, Math.min(0, mX));
				}
				// Check if vertical scroll is needed
				if (rotatedMap.getHeight() * mScale > this.getHeight()) {
					mY -= distanceY / mScale;
					mY = Math.max(-HEIGHT, Math.min(0, mY));
				}
			} else {
				// Check if horizontal scroll is needed
				if (mAndroid.getWidth() * mScale > this.getWidth()) {
					mX -= distanceX / mScale;
					mX = Math.max(-WIDTH, Math.min(0, mX));
				}
				// Check if vertical scroll is needed
				if (mAndroid.getHeight() * mScale > this.getHeight()) {
					mY -= distanceY / mScale;
					mY = Math.max(-HEIGHT, Math.min(0, mY));
				}
			}

			Log.d("RIPPLE", "mX:" + mX + " mY:" + mY);
			invalidate();
		}
		return true;
	}

	public void onShowPress(MotionEvent e) {

	}

	public boolean onSingleTapUp(MotionEvent e) {

		return false;

	}

	public void showOwnship(boolean show) {
		this.showOwnship = show;
		invalidate();
	}

	public void setNavControls(ImageView navControl) {
		this.navControl = navControl;
	}

	public boolean onDoubleTap(MotionEvent e) {
		// Log.d(TAG, "onDoubleTap ");

		if (mapUnlocked) {
			mHandler.removeMessages(MSG_ZOOMING_IN);

			mHandler.removeMessages(MSG_ZOOMING_OUT);
			mHandler.sendEmptyMessage(mScale > (MAX_ZOOM / 2) ? MSG_ZOOMING_OUT : MSG_ZOOMING_IN);
		}
		return true;
	}

	public boolean onDoubleTapEvent(MotionEvent e) {
		return false;
	}

	public boolean onSingleTapConfirmed(MotionEvent e) {
		return false;
	}

	Handler mHandler = new Handler() {
		@Override
		public void dispatchMessage(Message msg) {
			if (msg.what == MSG_ZOOMING_IN) {
				mScale += 0.1f;

				if (mScale > MAX_ZOOM) {
					mScale = MAX_ZOOM;
				} else {
					sendEmptyMessage(msg.what);
				}

				invalidate();
			} else if (msg.what == MSG_ZOOMING_OUT) {
				mScale -= 0.1f;
				if (mScale < 1) {
					mScale = 1;
				} else {
					sendEmptyMessage(msg.what);
				}
				invalidate();
			}
		}
	};
	private boolean mapUnlocked = true;

	public static Bitmap getBitmapFromURL(String src) {
		try {

			URL url = new URL(src);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();

			if (connection == null) {
				return null;
			}
			String contentType = connection.getHeaderField("Content-Type");
			if (contentType == null) {
				return null;
			}
			boolean isImage = contentType.startsWith("image/");
			if (isImage) {

				InputStream input = connection.getInputStream();
				Bitmap myBitmap = BitmapFactory.decodeStream(input);

				return myBitmap;
			} else {
				return null;
			}
		} catch (IOException e) {

			return null;
		}
	}

	public Boolean setImage(String airport) {

		mAndroid = getBitmapFromURL("http://flightaware.com/resources/airport/" + airport
					+ "/APD/AIRPORT+DIAGRAM/png/1");

		if (mAndroid != null) {

			this.WIDTH = mAndroid.getWidth();
			this.HEIGHT = mAndroid.getHeight();

			return true;
		} else {
			return false;
		}

	}

	public void updatePosition(float hdg, double lat, double lon) {

		Log.d("RIPPLE", "New Nav Point");
		// Let's find out the bearing and distance between
		// the first reference point (Point1) and our new
		// location (Point 2)

		Point point1 = refPointsLatLon.get(0);
		Point point2 = new Point(lat, lon);

		double distance = distanceBetweenTwoPoints(point1, point2);
		Log.d("RIPPLE", "Distance:" + distance);
		double distanceInPixels = distance * pixelScaleFactor;
		Log.d("RIPPLE", "Distance In Pixels:" + distanceInPixels);
		double bearing = (Math.toDegrees(bearingBetweenTwoPoints(point1, point2)) + 360) % 360;
		Log.d("RIPPLE", "Bearing:" + bearing);

		// We adjust for the missing top quadrant by subtracting
		// 90 for the bearing then adjust for the offset
		double bearingPixels = bearing - 90 + bearingOffset;
		Log.d("RIPPLE", "BearingPixels:" + bearingPixels);

		double diffX = distanceInPixels * Math.cos(Math.toRadians(bearingPixels));
		double diffY = distanceInPixels * Math.sin(Math.toRadians(bearingPixels));

		Log.d("RIPPLE", "DIFF-X:" + diffX);
		Log.d("RIPPLE", "DIFF-Y:" + diffY);

		// now lets create a new "NavPoint" with the new values adjusted for
		// the x,y of the reference point

		NavPoint newNavPoint = new NavPoint();
		newNavPoint.setX((int) (refPointsXY.get(0).getX() + diffX));
		newNavPoint.setY((int) (refPointsXY.get(0).getY() + diffY));
		newNavPoint.setBearing(hdg);

		navLocation = newNavPoint;
		if (mapUnlocked) {
			invalidate();
		}
	}

	private class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
		@Override
		public boolean onScale(ScaleGestureDetector detector) {
			if (mapUnlocked) {
				mScale *= detector.getScaleFactor();

				// Don't let the object get too small or too large.
				mScale = Math.max(0.5f, Math.min(mScale, 5.0f));

				invalidate();
			}
			return true;
		}
	}

	
	@Override
	public void onLongPress(MotionEvent arg0) {

		mapUnlocked = !mapUnlocked;

		if (mapUnlocked) {
			Toast.makeText(getContext(), "Map is unlocked", Toast.LENGTH_SHORT).show();
		} else {
			Toast.makeText(getContext(), "Map is locked", Toast.LENGTH_SHORT).show();
		}
		invalidate();

	}

}
