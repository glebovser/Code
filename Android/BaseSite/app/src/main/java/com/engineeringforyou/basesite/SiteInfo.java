package com.engineeringforyou.basesite;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

/**
 * Created by Сергей on 30.09.2017.
 */

public class SiteInfo extends Activity {
    String siteNumber;
    double lat, lng;
    String[] text;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.site_info);
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            siteNumber = extras.getString("site");
            lng = extras.getDouble("lng");
            lat = extras.getDouble("lat");
            text = extras.getStringArray("lines");
        }
        ListView lvMain = (ListView) findViewById(R.id.descriptions);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, text);
        lvMain.setAdapter(adapter);
    }

    public void onClick2(View view) {
        Log.v("aaa", "onClick2");
        Intent intent = new Intent(this, MapsActivity.class);
        intent.putExtra("lat", lat);
        intent.putExtra("lng", lng);
        intent.putExtra("site", siteNumber);
        switch (view.getId()) {
            case R.id.btnSearchNear:
                Log.v("aaa", "btnSearchNear  MAP_BS_SITE");
                intent.putExtra("next", MapsActivity.MAP_BS_SITE);
                break;
            case R.id.button:
                Log.v("aaa", "button");
                intent.putExtra("next", MapsActivity.MAP_BS_ONE);
                Log.v("aaa", "MAP_BS_ONE ++++++ = " + siteNumber);
                break;
        }
        startActivity(intent);
    }
}