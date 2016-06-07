using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Sensor as Sens;
using Toybox.ActivityMonitor as Act;
using Toybox.Attention as Att;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Application as App;
using Toybox.UserProfile as UserProfile;


class YotaClock2View extends Ui.WatchFace {
    var font14Regular;
    var tickmarks, batteryIcon, stepsIcon, heartIcon, heartZone1Icon, heartZone2Icon, heartZone3Icon, heartZone4Icon, heartZone5Icon, bleIcon;    
    var heartRate;

    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {        
        font14Regular  = Ui.loadResource(Rez.Fonts.roboto14Regular);
        tickmarks      = Ui.loadResource(Rez.Drawables.tickmarks);
        batteryIcon    = Ui.loadResource(Rez.Drawables.batteryIcon);
        stepsIcon      = Ui.loadResource(Rez.Drawables.stepsIcon);
        heartIcon      = Ui.loadResource(Rez.Drawables.heartIcon);
        heartZone1Icon = Ui.loadResource(Rez.Drawables.heartZone1Icon);
        heartZone2Icon = Ui.loadResource(Rez.Drawables.heartZone2Icon);
        heartZone3Icon = Ui.loadResource(Rez.Drawables.heartZone3Icon);
        heartZone4Icon = Ui.loadResource(Rez.Drawables.heartZone4Icon);
        heartZone5Icon = Ui.loadResource(Rez.Drawables.heartZone5Icon);
        bleIcon        = Ui.loadResource(Rez.Drawables.bleIcon);        
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        View.onUpdate(dc);

        // General
        var width       = dc.getWidth();
        var height      = dc.getHeight();
        var clockTime   = Sys.getClockTime();
        var nowinfo     = Greg.info(Time.now(), Time.FORMAT_SHORT);
        var actinfo     = Act.getInfo();
        var systemStats = Sys.getSystemStats();
        var hrIter      = Act.getHeartRateHistory(null, true);
        var hr          = hrIter.next();        
        var steps       = actinfo.steps;
        var stepGoal    = actinfo.stepGoal;
        var stepsString = steps.toString();
        var kcal        = actinfo.calories;
        var kcalString  = kcal.toString() + " kcal";  
        var bpm         = (hr.heartRate != Act.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : 0;
        var bpmString   = bpm > 0 ? bpm.toString() : "";
        var charge      = systemStats.battery;                
        var smallFont   = font14Regular;
        var dayOfWeek   = nowinfo.day_of_week;
        var connected   = Sys.getDeviceSettings().phoneConnected;
        
        var hour;
        var minute;
        var dateString;
        if (1 == dayOfWeek) { 
            dateString = Lang.format("SU " + nowinfo.day.format("%02d")); 
        } else if (2 == dayOfWeek) {
            dateString = Lang.format("MO " + nowinfo.day.format("%02d"));
        } else if (3 == dayOfWeek) {
            dateString = Lang.format("TU " + nowinfo.day.format("%02d"));
        } else if (4 == dayOfWeek) {
            dateString = Lang.format("WE " + nowinfo.day.format("%02d"));
        } else if (5 == dayOfWeek) {
            dateString = Lang.format("TH " + nowinfo.day.format("%02d"));
        } else if (6 == dayOfWeek) {
            dateString = Lang.format("FR " + nowinfo.day.format("%02d"));
        } else {
            dateString = Lang.format("SA " + nowinfo.day.format("%02d")); 
        }
        
        var profile = UserProfile.getProfile();
        var gender;
        var userWeight;
        var userHeight;
        var userAge;
        
        if (profile == null) {
            gender     = Application.getApp().getProperty("Gender");
            userWeight = Application.getApp().getProperty("Weight");
            userHeight = Application.getApp().getProperty("Height");
            userAge    = Application.getApp().getProperty("Age");
        } else {
            gender     = profile.gender;
            userWeight = profile.weight / 1000d;
            userHeight = profile.height;
            userAge    = nowinfo.year - profile.birthYear;
        }        
        
        var goalMen    = 66d + (13.7 * userWeight) + (5 * userHeight) - (6.8 * userAge);
        var goalWoman  = 655d + (9.6 * userWeight) + (1.8 * userHeight) - (4.7 * userAge);
        var goal       = gender == 1 ? goalMen : goalWoman;
        
        
        var showBpmZones = Application.getApp().getProperty("BpmZones");
        var maxBpm       = gender == 1 ? (223 - 0.9 * userAge).toNumber() : (226 - 1.0 * userAge).toNumber();        
        var bpmZone1     = (0.5 * maxBpm).toNumber();
        var bpmZone2     = (0.6 * maxBpm).toNumber();
        var bpmZone3     = (0.7 * maxBpm).toNumber();
        var bpmZone4     = (0.8 * maxBpm).toNumber();
        var bpmZone5     = (0.9 * maxBpm).toNumber();
        var currentZone;
                
        if (bpm >= bpmZone5) {
            currentZone = 5;
        } else if (bpm >= bpmZone4) {
            currentZone = 4;
        } else if (bpm >= bpmZone3) {
            currentZone = 3;
        } else if (bpm >= bpmZone2) {
            currentZone = 2;
        } else {
            currentZone = 1;
        }
                
            
        // Tickmarks
        dc.drawBitmap(0, 0, tickmarks);
        
        // Battery
        dc.drawBitmap(95, 22, batteryIcon);
        dc.setColor(charge < 20 ? Gfx.COLOR_RED : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(97, 24 , 20.0 * charge / 100, 7);
    
        // Date        
        //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        //dc.fillRoundedRectangle(124, 81, 55, 18, 4);
        //dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(178, 79, smallFont, dateString, Gfx.TEXT_JUSTIFY_RIGHT);
    
        // KCal
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width * 0.5, 43, smallFont, kcalString, Gfx.TEXT_JUSTIFY_CENTER);        

        // BPM
        if (showBpmZones) {
            if(currentZone == 1) {
                dc.drawBitmap(40, 82, heartZone1Icon);
            } else if (currentZone == 2) {
                dc.drawBitmap(40, 82, heartZone2Icon);
            } else if (currentZone == 3) {
                dc.drawBitmap(40, 82, heartZone3Icon);
            } else if (currentZone == 4) {
                dc.drawBitmap(40, 82, heartZone4Icon);
            } else if (currentZone == 5) {
                dc.drawBitmap(40, 82, heartZone5Icon);
            } else {
                dc.drawBitmap(40, 82, heartIcon);
            }
        } else {
            dc.drawBitmap(40, 82, heartIcon);
        }
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);        
        dc.drawText(60, 78, smallFont, bpmString, Gfx.TEXT_JUSTIFY_LEFT);
        
        // Steps
        dc.drawBitmap(78, 120, stepsIcon);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(93, 116, smallFont, stepsString, Gfx.TEXT_JUSTIFY_LEFT);
    
        // BLE
        if (connected) { dc.drawBitmap(104, 142, bleIcon); }        
        
    
        // Left Segments (Steps)    
        var stepsPerSegment1 = (stepGoal.toDouble() / 5.0).toNumber();
        var stepsPerSegment2 = (2.0 * stepsPerSegment1).toNumber();
        var stepsPerSegment3 = (3.0 * stepsPerSegment1).toNumber();
        var stepsPerSegment4 = (4.0 * stepsPerSegment1).toNumber();
        var stepsPerSegment5 = (5.0 * stepsPerSegment1).toNumber();
                
        var activeSegments;
        if (steps >= stepsPerSegment5) {
            activeSegments = 5;
        } else if (steps >= stepsPerSegment4) {
            activeSegments = 4;
        } else if (steps >= stepsPerSegment3) {
            activeSegments = 3;
        } else if (steps >= stepsPerSegment2) {
            activeSegments = 2;
        } else if (steps >= stepsPerSegment1) {
            activeSegments = 1;
        } else {
            activeSegments = 0;
        }
                
        dc.setPenWidth(11);           
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -146, -126);
        dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
        var seg1FillAngle = steps > stepsPerSegment1 ? -146 : (-126 - ((1 - (stepsPerSegment1 - steps.toDouble()) / stepsPerSegment1)) * 20.0).toNumber();
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, seg1FillAngle == -126 ? -127 : seg1FillAngle, -126);

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -168, -148);
        if (steps >= stepsPerSegment1) {
            dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
            var seg2FillAngle = steps >= stepsPerSegment2 ? -168 : (-148 - ((1 - (stepsPerSegment2 - steps.toDouble()) / stepsPerSegment1)) * 20.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, seg2FillAngle == -148 ? -149 : seg2FillAngle, -148);
        }        

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -190, -170);        
        if (steps >= stepsPerSegment2) {            
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            var seg3FillAngle = steps >= stepsPerSegment3 ? -190 : (-170 - ((1 - (stepsPerSegment3 - steps.toDouble()) / stepsPerSegment1)) * 20.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, seg3FillAngle == -170 ? -171 : seg3FillAngle, -170);
        }
        
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -212, -192);
        if (steps >= stepsPerSegment3) {            
            dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
            var seg4FillAngle = steps >= stepsPerSegment4 ? -212 : (-192 - ((1 - (stepsPerSegment4 - steps.toDouble() )/ stepsPerSegment1)) * 20.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, seg4FillAngle == -192 ? -193 : seg4FillAngle, -192);
        }
        
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -234, -214);
        if (steps >= stepsPerSegment4) {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
            var seg5FillAngle = steps >= stepsPerSegment5 ? -234 : (-214 - ((1 - (stepsPerSegment5 - steps.toDouble()) / stepsPerSegment1)) * 20.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, seg5FillAngle == -214 ? -215 : seg5FillAngle, -214);
        }
        

        // Right Bar
        var endAngle = kcal == 0 ? -53.99999 : ((kcal.toDouble() / goal.toDouble()) * 108d - 54.0).toNumber();        
                       
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -54, 54);        
        
        dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(width * 0.5, height * 0.5, 101, 0, -54, endAngle > 54 ? 54 : endAngle);
        
        if (kcal > goal) {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
            var endAngle = (((kcal - goal) / goal.toDouble()) * 108.0 - 54.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, -54, endAngle > 54 ? 54 : endAngle);
        }
        if (kcal > 2 * goal) {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
            var endAngle = (((kcal - (2 * goal)) / goal.toDouble()) * 108.0 - 54.0).toNumber();
            dc.drawArc(width * 0.5, height * 0.5, 101, 0, -54, endAngle > 54 ? 54 : endAngle);
        }
        
                
        // Hour
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        hour = (((clockTime.hour % 12) * 60) + clockTime.min);
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        drawHand(dc, hour, 53, 5);

        // Minute        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        minute = ( clockTime.min / 60.0) * Math.PI * 2;
        drawHand(dc, minute, 85, 5);

        // Knob        
        dc.fillCircle(width * 0.5, height * 0.5, 4);
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(width * 0.5, height * 0.5, 4);
    }

    function drawHand(dc, angle, length, width) {
        // Map out the coordinates of the watch hand
        var coords  = [ [-(width/2),0], [-(width/2), -length], [width/2, -length], [width/2, 0] ];
        var result  = new [4];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos     = Math.cos(angle);
        var sin     = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX + x, centerY + y];
        }

        // Hour
        //dc.fillRoundedRectangle(105, 37, 5, 53, 5);
        // Minute
        //dc.fillRoundedRectangle(105, 5, 5, 85, 5);


        // Draw the polygon
        dc.fillPolygon(result);
    }


    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
