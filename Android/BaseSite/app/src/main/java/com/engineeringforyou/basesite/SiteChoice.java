package com.engineeringforyou.basesite;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;


/**
 * Created by Сергей on 30.09.2017.
 */

public class SiteChoice extends Activity {
    String siteNumber;
    double lat, lng;
    String[] param1,param2,id;
    ListView listView;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.site_choice);
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            param1 = extras.getStringArray("param1");
            param2 = extras.getStringArray("param2");
            id = extras.getStringArray("id");
        }
        listView = (ListView) findViewById(R.id.sites);
        ArrayList<HashMap<String, String>> arrayList = new ArrayList<>();
        HashMap<String, String> map;
        for (int i = 0; i < param1.length; i++) {
            map = new HashMap<>();
            map.put("param1", param1[i]);
            map.put("param2", param2[i]);
            arrayList.add(map);
        }
        SimpleAdapter adapter = new SimpleAdapter(this, arrayList, android.R.layout.simple_list_item_2,
                new String[]{"param1", "param2"},
                new int[]{android.R.id.text1, android.R.id.text2});
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int pos, long l) {
                Log.v("aaa", "position choice = " + pos);
                Log.v("aaa", "id[pos] = " + id[pos]);
                Log.v("aaa", "String.valueOf(id[pos]) = " + String.valueOf(id[pos]));
                Cursor cursor = new DBHelper
                        (getApplicationContext()).
                       siteSearch
                               (String.valueOf(id[pos]), 3);
                if (cursor == null) {
                    Toast.makeText(getApplicationContext(), "Ошибка в БД", Toast.LENGTH_SHORT).show();
                    Log.v("aaa", "Ошибка в Курсоре ");
                    return;
                }

                double lat, lng;
                cursor.moveToFirst();
                String[] headers = getResources().getStringArray(R.array.columns);
                String[] text = new String[headers.length];
                for (int i = 0; i < text.length; i++) {
                    Log.v("aaa", i + " " + headers[i]);
                    text[i] = cursor.
                            getString(cursor.
                                    getColumnIndex(headers[i]));
                    Log.v("aaa", i + " " + text[i]);
                }
                lat = cursor.getDouble(cursor.getColumnIndex("GPS_Latitude"));//.replace(',', '.');
                lng = cursor.getDouble(cursor.getColumnIndex("GPS_Longitude"));//.replace(',', '.');
                String site = cursor.getString(cursor.getColumnIndex("SITE"));
                Log.v("aaa", "SITE  ==" + site);
                cursor.close();
                Intent intent = new Intent(getApplicationContext(), SiteInfo.class);
                intent.putExtra("lines", text);
                intent.putExtra("lat", lat);
                intent.putExtra("lng", lng);
                intent.putExtra("site", site);
                startActivity(intent);
            }
        });
    }
}