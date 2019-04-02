package com.appapply.igflexin.utils

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.AttributeSet
import androidx.annotation.RestrictTo
import androidx.appcompat.content.res.AppCompatResources
import androidx.appcompat.widget.AppCompatButton
import androidx.core.widget.TextViewCompat

import com.appapply.igflexin.R

/**
 * A custom button that supports using vector drawables with the `android:drawable[Start/End/Top/Bottom]` attribute pre-L.
 *
 *
 * AppCompat can only load vector drawables with srcCompat pre-L and doesn't provide a similar
 * compatibility attribute for compound drawables. Thus, we must load compound drawables at runtime
 * using AppCompat and inject them into the button to support pre-L devices.
 */
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
class SupportVectorDrawablesButton : AppCompatButton {
    constructor(context: Context) : super(context) {}

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        initSupportVectorDrawablesAttrs(attrs)
    }

    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        initSupportVectorDrawablesAttrs(attrs)
    }

    /**
     * Loads the compound drawables natively on L+ devices and using AppCompat pre-L.
     *
     *
     * *Note:* If we ever need a TextView with compound drawables, this same technique is
     * applicable.
     */
    private fun initSupportVectorDrawablesAttrs(attrs: AttributeSet?) {
        if (attrs == null) {
            return
        }

        val attributeArray = context.obtainStyledAttributes(
                attrs,
                R.styleable.SupportVectorDrawablesButton)

        var drawableStart: Drawable? = null
        var drawableEnd: Drawable? = null
        var drawableTop: Drawable? = null
        var drawableBottom: Drawable? = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            drawableStart = attributeArray.getDrawable(
                    R.styleable.SupportVectorDrawablesButton_drawableStartCompat)
            drawableEnd = attributeArray.getDrawable(
                    R.styleable.SupportVectorDrawablesButton_drawableEndCompat)
            drawableTop = attributeArray.getDrawable(
                    R.styleable.SupportVectorDrawablesButton_drawableTopCompat)
            drawableBottom = attributeArray.getDrawable(
                    R.styleable.SupportVectorDrawablesButton_drawableBottomCompat)
        } else {
            val drawableStartId = attributeArray.getResourceId(
                    R.styleable.SupportVectorDrawablesButton_drawableStartCompat, -1)
            val drawableEndId = attributeArray.getResourceId(
                    R.styleable.SupportVectorDrawablesButton_drawableEndCompat, -1)
            val drawableTopId = attributeArray.getResourceId(
                    R.styleable.SupportVectorDrawablesButton_drawableTopCompat, -1)
            val drawableBottomId = attributeArray.getResourceId(
                    R.styleable.SupportVectorDrawablesButton_drawableBottomCompat, -1)

            if (drawableStartId != -1) {
                drawableStart = AppCompatResources.getDrawable(context, drawableStartId)
            }
            if (drawableEndId != -1) {
                drawableEnd = AppCompatResources.getDrawable(context, drawableEndId)
            }
            if (drawableTopId != -1) {
                drawableTop = AppCompatResources.getDrawable(context, drawableTopId)
            }
            if (drawableBottomId != -1) {
                drawableBottom = AppCompatResources.getDrawable(context, drawableBottomId)
            }
        }

        TextViewCompat.setCompoundDrawablesRelativeWithIntrinsicBounds(
                this, drawableStart, drawableTop, drawableEnd, drawableBottom)

        attributeArray.recycle()
    }
}