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

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;


public class DepRunwayBar extends View {

	private Handler mHandler;
	private Resources myResources;
	private Drawable rwthumb;
	private Drawable sliderbg;
	private String runwayText;
	private Rect thumbBounds;
	private Rect background;
	private int thumbX1;
	private int thumbX2;
	private int thumbY1;
	private int thumbY2;
	private int thirdWidth;
	private Boolean onThumb = false;
	private int rwyStatus = 0;
	int id;
	private String runwayLeft;
	private String runwayRight;
	private String departText = "DEPART";

	public DepRunwayBar(Context context) {
		super(context);
		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);
		mHandler = null;

	}

	public DepRunwayBar(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);

		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);
		mHandler = null;
	}

	public DepRunwayBar(Context context, AttributeSet attrs) {
		super(context, attrs);
		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);
		mHandler = null;
	}

	@Override
	protected synchronized void onDraw(Canvas canvas) {

		super.onDraw(canvas);

		// background = new Rect(canvas.getClipBounds().left+10, 5,
		// canvas.getClipBounds().right-10 , 40);
		background = new Rect(0, 5, canvas.getClipBounds().right, 40);
		// Set-Up scaling for Thumb
		thirdWidth = (background.right) / 3;

		// Set up Background
		sliderbg.setBounds(background);
		sliderbg.draw(canvas);

		thirdWidth = (canvas.getClipBounds().right) / 3;

		if (thumbBounds == null) {
			setThumbBounds(rwyStatus);
		}

		// Set-Up Paint for text
		Paint rwyTextPaint = new Paint();
		rwyTextPaint.setColor(Color.WHITE);
		rwyTextPaint.setShadowLayer(2, 2, 2, Color.BLACK);
		rwyTextPaint.setTypeface(Typeface.DEFAULT_BOLD);
		rwyTextPaint.setTextAlign(Paint.Align.CENTER);
		rwyTextPaint.setAntiAlias(true);

		Paint barTextPaint = new Paint();
		barTextPaint.setTextSize(18);
		barTextPaint.setTypeface(Typeface.DEFAULT_BOLD);
		barTextPaint.setAntiAlias(true);

		Rect textBounds;
		float center;

		// Left Runway Paint

		if (rwyStatus == 0) {
			barTextPaint.setColor(Color.argb(90, 0, 0, 0));
			barTextPaint.setTextAlign(Paint.Align.LEFT);
			textBounds = new Rect();
			barTextPaint.getTextBounds(runwayLeft, 0, runwayLeft.length(), textBounds);
			center = background.exactCenterY() + (textBounds.height() / 2);
			canvas.drawText(runwayLeft, background.left + 10, center, barTextPaint);

			// Right Runway Paint

			barTextPaint.setColor(Color.argb(90, 0, 0, 0));
			barTextPaint.setTextAlign(Paint.Align.RIGHT);
			textBounds = new Rect();
			barTextPaint.getTextBounds(runwayRight, 0, runwayRight.length(), textBounds);
			center = background.exactCenterY() + (textBounds.height() / 2);
			canvas.drawText(runwayRight, background.right - 10, center, barTextPaint);
		} else {

			barTextPaint.setShadowLayer(2, 2, 2, Color.BLACK);
			if (rwyStatus == 1) {
				barTextPaint.setColor(Color.rgb(255, 255, 255));
				barTextPaint.setTextAlign(Paint.Align.LEFT);
				textBounds = new Rect();
				barTextPaint.getTextBounds(departText, 0, departText.length(), textBounds);
				center = background.exactCenterY() + (textBounds.height() / 2);
				canvas.drawText(departText, background.left + 20, center, barTextPaint);
			} else {
				barTextPaint.setColor(Color.rgb(255, 255, 255));
				barTextPaint.setTextAlign(Paint.Align.RIGHT);
				textBounds = new Rect();
				barTextPaint.getTextBounds(departText, 0, departText.length(), textBounds);
				center = background.exactCenterY() + (textBounds.height() / 2);
				canvas.drawText(departText, background.right - 20, center, barTextPaint);
			}
		}

		// Not Set
		if (rwyStatus == 0) {

			rwthumb.setBounds(thumbBounds);
			rwthumb.draw(canvas);

			Rect bounds = new Rect();
			rwyTextPaint.setTextSize(18);
			String notSet = "UNK";
			rwyTextPaint.getTextBounds(notSet, 0, notSet.length(), bounds);
			center = rwthumb.getBounds().exactCenterY() + (bounds.height() / 2);
			canvas.drawText(notSet, rwthumb.getBounds().exactCenterX(), center, rwyTextPaint);

		}

		// Right Runway
		if (rwyStatus == 1) {

			rwthumb.setBounds(thumbBounds);
			rwthumb.draw(canvas);

			Rect bounds = new Rect();
			rwyTextPaint.setTextSize(18);
			rwyTextPaint.getTextBounds(runwayRight, 0, runwayRight.length(), bounds);
			center = rwthumb.getBounds().exactCenterY() + (bounds.height() / 2);
			canvas.drawText(runwayRight, rwthumb.getBounds().exactCenterX(), center, rwyTextPaint);

		}

		// Left Runway
		if (rwyStatus == 2) {

			rwthumb.setBounds(thumbBounds);
			rwthumb.draw(canvas);

			Rect bounds = new Rect();
			rwyTextPaint.setTextSize(18);
			rwyTextPaint.getTextBounds(runwayLeft, 0, runwayLeft.length(), bounds);
			center = rwthumb.getBounds().exactCenterY() + (bounds.height() / 2);
			canvas.drawText(runwayLeft, rwthumb.getBounds().exactCenterX(), center, rwyTextPaint);

		}

	}

	public void setRunwayText(String text) {
		runwayText = text;
		String runwayParts[] = text.split("-");
		runwayLeft = runwayParts[0];
		runwayRight = runwayParts[1];
	}

	public String getRunwayText() {
		return runwayText;
	}

	public void setRunwayStatus(int status) {

		if (status == 1 || status == 2) {

		} else {
		}

		rwyStatus = status;
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		// TODO Auto-generated method stub
		int parentWidth = MeasureSpec.getSize(widthMeasureSpec);
		int parentHeight = MeasureSpec.getSize(heightMeasureSpec);
		this.setMeasuredDimension(parentWidth, parentHeight);
		// this.setLayoutParams(new LayoutParams(parentWidth/2,parentHeight));
		// super.onMeasure(widthMeasureSpec, heightMeasureSpec);
	}

	public void getThumbBounds() {

		thumbX1 = thumbBounds.left;
		thumbY1 = thumbBounds.top;
		thumbX2 = thumbBounds.right;
		thumbY2 = thumbBounds.bottom;

	}

	public void setThumbBounds(int status) {

		if (status == 0) {
			sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
			thumbBounds = new Rect(background.centerX() - (thirdWidth / 2), background.top - 2,
					background.centerX() - (thirdWidth / 2) + thirdWidth, background.bottom + 2);

		}

		if (status == 1) {
			sliderbg = myResources.getDrawable(R.drawable.dep_slider_set);
			thumbBounds = new Rect(background.right - thirdWidth - 5, background.top - 2,
					background.right - 5, background.bottom + 2);
			this.mHandler.sendEmptyMessage(this.id);

		}

		if (status == 2) {
			sliderbg = myResources.getDrawable(R.drawable.dep_slider_set);
			thumbBounds = new Rect(background.left + 5, background.top - 2, background.left + 5
					+ thirdWidth, background.bottom + 2);
			this.mHandler.sendEmptyMessage(this.id);
		}

		invalidate();
	}

	public boolean onTouchEvent(MotionEvent event) {
		int eventaction = event.getAction();

		int X = (int) event.getX();
		int Y = (int) event.getY();
		switch (eventaction) {

		case MotionEvent.ACTION_DOWN:

			getThumbBounds();

			if (X > thumbX1 && X < thumbX2 && Y > thumbY1 && Y < thumbY2
					&& thumbBounds.contains(X, Y)) {
				onThumb = true;
			}

			break;

		case MotionEvent.ACTION_MOVE:

			if (onThumb) {

				if (thumbBounds.left >= (background.left)
						&& thumbBounds.right <= (background.right)) {

					// Calculate distance to move
					int distance = X - thumbBounds.centerX();

					if (rwyStatus == 2) {

						if (distance < 0) {
							break;
						} else {
							// Move Thumb
							thumbBounds.left = thumbBounds.left + (distance);
							thumbBounds.right = thumbBounds.right + (distance);
							break;
						}
					}

					if (rwyStatus == 1 || rwyStatus == 4) {

						if (distance > 0) {
							break;
						} else {
							// Move Thumb
							thumbBounds.left = thumbBounds.left + (distance);
							thumbBounds.right = thumbBounds.right + (distance);
							break;
						}
					}

					// Move Thumb

					thumbBounds.left = thumbBounds.left + (distance);
					thumbBounds.right = thumbBounds.right + (distance);
				}

			}

			if (!(thumbBounds.contains(X, Y))) {
				onThumb = false;
			}

			break;

		case MotionEvent.ACTION_UP:
			// touch drop - just do things here after dropping

			// Create three regions
			// Scale for third of width

			// Left
			int LeftX1 = background.left;
			int LeftX2 = background.left + thirdWidth;

			// Middle
			int MidX1 = LeftX2 + 1;
			int MidX2 = MidX1 + thirdWidth;

			// Right
			int RightX1 = MidX2 + 1;
			int RightX2 = background.right;

			if (thumbBounds.centerX() >= LeftX1 && thumbBounds.centerX() <= LeftX2) {

				setThumbBounds(2);
				setRunwayStatus(2);
			}

			if (thumbBounds.centerX() >= MidX1 && thumbBounds.centerX() <= MidX2) {

				setThumbBounds(0);
				setRunwayStatus(0);
			}

			if (thumbBounds.centerX() >= RightX1 && thumbBounds.centerX() <= RightX2) {

				setThumbBounds(1);
				setRunwayStatus(1);

			}

			onThumb = false;
			break;
		}
		// redraw the canvas
		invalidate();
		return true;

	}

	public void setRwyId(int i) {
		id = i;
	}

	public void setHandler(Handler mHandler) {
		this.mHandler = mHandler;
	}

	public int getRwyId() {

		return this.id;
	}

	public int getRunwayStatus() {
		return this.rwyStatus;
	}

	public String getRunwayRightText() {
		return this.runwayRight;

	}

	public String getRunwayLeftText() {
		return this.runwayLeft;

	}
}
