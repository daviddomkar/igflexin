package com.appapply.igflexin

import android.arch.lifecycle.ViewModel
import android.arch.lifecycle.ViewModelProviders
import android.content.res.Resources
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.NavigationUI
import kotlinx.android.synthetic.main.main_activity.*

class MainActivity : AppCompatActivity() {

    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)

        setSupportActionBar(toolbar)

        /*
        val host: NavHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment) as NavHostFragment

        navController = host.navController

        setupActionBar()


        navController.addOnNavigatedListener { _, destination ->
            val dest: String = try {
                resources.getResourceName(destination.id)
            } catch (e: Resources.NotFoundException) {
                Integer.toString(destination.id)
            }

            Toast.makeText(this@MainActivity, "Navigated to $dest",
                    Toast.LENGTH_SHORT).show()
            Log.d("MainActivity", "Navigated to $dest")
        }*/
    }

    private fun setupActionBar() {
        NavigationUI.setupActionBarWithNavController(this, navController, drawerLayout)
    }

    override fun onSupportNavigateUp(): Boolean {
        return NavigationUI.navigateUp(drawerLayout, navController)
    }
}
