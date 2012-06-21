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
/***
	Copyright (c) 2008-2011 CommonsWare, LLC
	Licensed under the Apache License, Version 2.0 (the "License"); you may not
	use this file except in compliance with the License. You may obtain	a copy
	of the License at http://www.apache.org/licenses/LICENSE-2.0. Unless required
	by applicable law or agreed to in writing, software distributed under the
	License is distributed on an "AS IS" BASIS,	WITHOUT	WARRANTIES OR CONDITIONS
	OF ANY KIND, either express or implied. See the License for the specific
	language governing permissions and limitations under the License.
	
	From _The Busy Coder's Guide to Advanced Android Development_
		http://commonsware.com/AdvAndroid
 */

package com.mitre.holdshort;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.TranslateAnimation;
import android.widget.LinearLayout;
import android.widget.TextView;

public class SlidingPanel extends LinearLayout {
	private int speed2 = 500;
	public boolean isOpen = true;
	private SlidingPanel slidingPanel;
	private Context ctx;
	private LinearLayout runwayContainer;
	private View headerDropShadow;
	private TextView openCloseText;
	private Handler handler;

	public SlidingPanel(final Context ctxt, AttributeSet attrs) {
		super(ctxt, attrs);
		this.slidingPanel = this;
		this.ctx = ctxt;

	}

	public void toggle() {

		TranslateAnimation anim = null;

		isOpen = !isOpen;

		if (isOpen) {
			runwayContainer.setVisibility(LinearLayout.VISIBLE);
			anim = new TranslateAnimation(0.0f, 0.0f, -(runwayContainer.getHeight()), -2.0f);
			anim.setZAdjustment(Animation.ZORDER_NORMAL);
			anim.setAnimationListener(collapseListener);
		} else {
			anim = new TranslateAnimation(0.0f, 0.0f, 0.0f, -(runwayContainer.getHeight()));
			anim.setZAdjustment(Animation.ZORDER_NORMAL);
			anim.setAnimationListener(collapseListener);
		}

		anim.setDuration(speed2);
		anim.setInterpolator(AnimationUtils.loadInterpolator(ctx,
				android.R.anim.decelerate_interpolator));
		startAnimation(anim);
	}

	Animation.AnimationListener collapseListener = new Animation.AnimationListener() {

		public void onAnimationEnd(Animation animation) {
			if (!isOpen) {
				handler.sendEmptyMessage(1);
				runwayContainer.setVisibility(View.GONE);
				openCloseText.setText("open");
				// The following null animation just gets rid of screen flicker
				TranslateAnimation nullAnimation = new TranslateAnimation(0.0f, 0.0f, 0.0f, 0.0f);
				nullAnimation.setDuration(1);
				slidingPanel.startAnimation(nullAnimation);
			} else {
				openCloseText.setText("close");
				// The following null animation just gets rid of screen flicker
				TranslateAnimation nullAnimation = new TranslateAnimation(0.0f, 0.0f, 0.0f, 0.0f);
				nullAnimation.setDuration(1);
				slidingPanel.startAnimation(nullAnimation);

			}

		}

		public void onAnimationRepeat(Animation animation) {

		}

		public void onAnimationStart(Animation animation) {
			if (isOpen) {
				headerDropShadow.setVisibility(View.VISIBLE);
				handler.sendEmptyMessage(2);
			} else {

				AlphaAnimation fadeOut = new AlphaAnimation(1.0f, 0.0f);
				fadeOut.setDuration(speed2);
				fadeOut.setInterpolator(AnimationUtils.loadInterpolator(ctx,
						android.R.anim.accelerate_interpolator));
				headerDropShadow.setAnimation(fadeOut);
				headerDropShadow.setVisibility(View.INVISIBLE);
				
			}
		}

	};



	public void setRunwayContainer(LinearLayout runwayContainer2) {
		this.runwayContainer = runwayContainer2;
	}

	public void setHeaderDropShadow(View headerDropShadow) {
		this.headerDropShadow = headerDropShadow;
	}

	public void setOpenCloseTextView(TextView openClose) {
		this.openCloseText = openClose;
	}

	public void setHandler(Handler handler) {
		this.handler = handler;
	}

	
}
