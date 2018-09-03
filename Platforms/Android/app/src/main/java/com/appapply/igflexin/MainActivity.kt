package com.appapply.igflexin

import android.content.res.Resources
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.NavigationUI.navigateUp
import androidx.navigation.ui.NavigationUI.setupActionBarWithNavController

import kotlinx.android.synthetic.main.main_activity.*

class MainActivity : AppCompatActivity() {

    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)
        setSupportActionBar(toolbar)

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
        }
    }

    private fun setupActionBar() {
        setupActionBarWithNavController(this, navController, drawerLayout)
    }


    override fun onSupportNavigateUp(): Boolean {
        return navigateUp(drawerLayout, navController)
    }
}
