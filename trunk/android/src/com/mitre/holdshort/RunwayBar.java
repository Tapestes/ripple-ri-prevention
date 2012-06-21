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
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;


public class RunwayBar extends View {

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
	private String barText;
	private Boolean holdSet = false;
	private Boolean clearedSet = false;
	private Boolean notSet = false;
	private Boolean manualOverride = false;
	int id;

	public RunwayBar(Context context) {
		super(context);
		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);

	}

	public RunwayBar(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);

		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);
	}

	public RunwayBar(Context context, AttributeSet attrs) {
		super(context, attrs);
		setFocusable(true);
		myResources = getResources();

		// Set-Up Default
		sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
		rwthumb = myResources.getDrawable(R.drawable.new_thumb);

		setRunwayStatus(0);
	}

	@Override
	protected synchronized void onDraw(Canvas canvas) {

		super.onDraw(canvas);

		// background = new Rect(canvas.getClipBounds().left+10, 5,
		// canvas.getClipBounds().right-10 , 40);
		background = new Rect(10, 5, canvas.getClipBounds().right - 10, 40);
		// Set-Up scaling for Thumb
		thirdWidth = (background.right) / 3;

		// Set up Background
		sliderbg.setBounds(background);
		sliderbg.draw(canvas);

		thirdWidth = (canvas.getClipBounds().right) / 3;

		if (thumbBounds == null) {
			setRunwayStatus(rwyStatus);
		}

		// Set-Up Paint for text
		Paint rwyTextPaint = new Paint();
		rwyTextPaint.setTextSize(18);
		rwyTextPaint.setColor(Color.WHITE);
		rwyTextPaint.setShadowLayer(2, 2, 2, Color.BLACK);
		rwyTextPaint.setTypeface(Typeface.DEFAULT_BOLD);
		rwyTextPaint.setTextAlign(Paint.Align.CENTER);
		rwyTextPaint.setAntiAlias(true);

		Paint barTextPaint = new Paint();
		barTextPaint.setTextSize(20);
		barTextPaint.setTypeface(Typeface.DEFAULT_BOLD);
		barTextPaint.setAntiAlias(true);

		// Draw Paint based on runway status

		// Not Set
		if (rwyStatus == 0) {

			// Cross Bar Paint
			barText = "Cross";
			barTextPaint.setColor(Color.argb(90, 0, 0, 0));
			barTextPaint.setTextAlign(Paint.Align.LEFT);
			canvas.drawText(barText, background.left + 20, background.centerY() + 7, barTextPaint);

			// Hold Bar Paint
			barText = "Hold";
			barTextPaint.setColor(Color.argb(90, 0, 0, 0));
			barTextPaint.setTextAlign(Paint.Align.RIGHT);
			canvas.drawText(barText, background.right - 20, background.centerY() + 7, barTextPaint);

			if (!onThumb) {
				setThumbBounds(rwyStatus);
			}
		}

		// Hold Short
		if (rwyStatus == 1) {
			barTextPaint.setColor(Color.WHITE);
			barTextPaint.setTextAlign(Paint.Align.LEFT);
			barTextPaint.setShadowLayer(2, 2, 2, Color.BLACK);
			canvas.drawText(barText, background.left + 20, background.centerY() + 7, barTextPaint);
			if (!onThumb) {
				setThumbBounds(rwyStatus);
			}
		}

		// Cleared to Cross
		if (rwyStatus == 2) {
			barTextPaint.setColor(Color.WHITE);
			barTextPaint.setTextAlign(Paint.Align.RIGHT);
			barTextPaint.setShadowLayer(2, 2, 2, Color.BLACK);
			canvas.drawText(barText, background.right - 10, background.centerY() + 7, barTextPaint);
			if (!onThumb) {
				setThumbBounds(rwyStatus);
			}
		}

		// Not Set
		if (rwyStatus == 3) {
			barTextPaint.setColor(Color.DKGRAY);
			barTextPaint.setTextAlign(Paint.Align.LEFT);
			canvas.drawText(barText, background.left + (thirdWidth + 10), background.centerY() + 5,
					barTextPaint);
			if (!onThumb) {
				setThumbBounds(rwyStatus);
			}
		}

		// ALERT
		if (rwyStatus == 4) {
			barTextPaint.setColor(Color.WHITE);
			barTextPaint.setTextAlign(Paint.Align.RIGHT);
			canvas.drawText(barText, background.right - (thirdWidth + 10),
					background.centerY() + 5, barTextPaint);
			if (!onThumb) {
				setThumbBounds(rwyStatus);
			}
		}

		rwthumb.setBounds(thumbBounds);
		rwthumb.draw(canvas);

		canvas.drawText(runwayText, rwthumb.getBounds().centerX(),
				rwthumb.getBounds().centerY() + 7, rwyTextPaint);

	}

	public void setRunwayText(String text) {
		runwayText = text;
	}

	public String getRunwayText() {
		return runwayText;
	}

	public void setRunwayStatus(int status) {

		if (status == 1) {
			holdSet = true;
		} else {
			holdSet = false;
		}

		if (status == 2) {
			clearedSet = true;
		} else {
			clearedSet = false;
		}

		if (status == 0) {
			notSet = true;
		} else {
			notSet = false;
		}
		if (background != null) {
			setThumbBounds(status);
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
			barText = "Hold Short of     Cleared to Cross";
			sliderbg = myResources.getDrawable(R.drawable.hatched_bg_layer);
			thumbBounds = new Rect(background.centerX() - (thirdWidth / 2), background.top - 2,
					background.centerX() - (thirdWidth / 2) + thirdWidth, background.bottom + 2);
		}

		if (status == 1) {
			barText = "Hold Short of";
			sliderbg = myResources.getDrawable(R.drawable.slider_hs);
			thumbBounds = new Rect(background.right - thirdWidth - 5, background.top - 2,
					background.right - 5, background.bottom + 2);
		}

		if (status == 2) {
			barText = "Cleared to Cross";
			sliderbg = myResources.getDrawable(R.drawable.slider_clear);
			thumbBounds = new Rect(background.left + 5, background.top - 2, background.left + 5
					+ thirdWidth, background.bottom + 2);
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

					if (rwyStatus == 1) {

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

			// Left
			int LeftX1 = background.left;
			int LeftX2 = background.left + thirdWidth;

			// Middle
			int MidX1 = LeftX2 + 1;
			int MidX2 = MidX1 + thirdWidth;

			// Right
			int RightX1 = MidX2 + 1;
			int RightX2 = background.right;

			if (!(thumbBounds.contains(X, Y))) {
				onThumb = false;
				if (thumbBounds.centerX() >= LeftX1 && thumbBounds.centerX() <= LeftX2) {

					if (rwyStatus != 2) {
						setRunwayStatus(2);
						setThumbBounds(2);
					}
				}

				if (thumbBounds.centerX() >= RightX1 && thumbBounds.centerX() <= RightX2) {
					if (rwyStatus != 1) {
						setRunwayStatus(1);
						setThumbBounds(1);
					}
				}
			}

			break;

		case MotionEvent.ACTION_UP:
			// touch drop - just do things here after dropping

			// Create three regions
			// Scale for third of width

			// Left
			LeftX1 = background.left;
			LeftX2 = background.left + thirdWidth;

			// Middle
			MidX1 = LeftX2 + 1;
			MidX2 = MidX1 + thirdWidth;

			// Right
			RightX1 = MidX2 + 1;
			RightX2 = background.right;

			if (thumbBounds.centerX() >= LeftX1 && thumbBounds.centerX() <= LeftX2) {

				if (rwyStatus != 2) {
					setRunwayStatus(2);
					setThumbBounds(2);
				}
			}

			if (thumbBounds.centerX() >= MidX1 && thumbBounds.centerX() <= MidX2) {

				if (rwyStatus != 0) {
					setRunwayStatus(0);
					setThumbBounds(0);
				}
			}

			if (thumbBounds.centerX() >= RightX1 && thumbBounds.centerX() <= RightX2) {
				if (rwyStatus != 1) {
					setRunwayStatus(1);
					setThumbBounds(1);
				}
			}

			onThumb = false;
			this.manualOverride = true;
			break;
		}
		// redraw the canvas
		invalidate();
		return true;

	}

	public void setRwyId(int i) {
		id = i;
	}

	public Boolean isHoldSet() {
		return holdSet;
	}

	public Boolean isClearedSet() {
		return clearedSet;
	}

	public Boolean isNotSet() {
		return notSet;
	}

	public Boolean isManual() {
		return this.manualOverride;
	}

	public void setManual(Boolean bool) {
		this.manualOverride = bool;
	}
}
