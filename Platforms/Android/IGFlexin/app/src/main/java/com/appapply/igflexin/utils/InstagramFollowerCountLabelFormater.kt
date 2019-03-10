package com.appapply.igflexin.utils

import android.content.Context
import com.jjoe64.graphview.helper.DateAsXAxisLabelFormatter
import java.text.DateFormat

class InstagramFollowerCountLabelFormater(private val context: Context, dateFormat: DateFormat): DateAsXAxisLabelFormatter(context, dateFormat) {
    override fun formatLabel(value: Double, isValueX: Boolean): String {
        if (isValueX)
            return super.formatLabel(value, isValueX)
        else {
            // return "HUH"
            return super.formatLabel(value, isValueX)
        }
    }
}