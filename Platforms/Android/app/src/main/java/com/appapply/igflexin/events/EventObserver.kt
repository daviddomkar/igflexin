package com.appapply.igflexin.events

import android.arch.lifecycle.Observer

class EventObserver<T>(private val onEventUnhandledContent: (T) -> Unit) : Observer<Event<T>> {
    override fun onChanged(event: Event<T>?) {
        event?.getContentIfNotHandled()?.let(onEventUnhandledContent)
    }
}