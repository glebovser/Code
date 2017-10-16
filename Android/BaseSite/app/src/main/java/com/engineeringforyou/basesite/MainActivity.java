package com.engineeringforyou.basesite;

import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    EditText siteView1, siteView2;
    String siteNumber, siteAddress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Log.v("aaa", "________________Запуск ");

        siteView1 = (EditText) findViewById(R.id.siteText);
        siteView2 = (EditText) findViewById(R.id.siteAddress);
    }

    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.button:
                //siteNumber = Integer.parseInt(siteView.getText().toString());
                siteNumber = (siteView1.getText().toString());
                Log.v("aaa", "siteNumber = -" + siteNumber + "-");
                if (siteNumber.length() == 0) {
                    Toast.makeText(this, "Поле поиска не заполнено", Toast.LENGTH_SHORT).show();
                    break;
                }
                siteData(new DBHelper(getApplicationContext()).
                        siteSearch(siteNumber, 1));
                break;

            case R.id.button2:
                siteAddress = (siteView2.getText().toString());
                Log.v("aaa", "siteAddress= -" + siteAddress + "+");
                if (siteAddress.length() == 0) {
                    Toast.makeText(this, "Поле поиска не заполнено", Toast.LENGTH_SHORT).show();
                    break;
                }
                siteData(new DBHelper(getApplicationContext()).
                        siteSearch(siteAddress, 2));
                break;

            case R.id.searchHere:
                Log.v("aaa", "btnSearchNear");
                Intent intent = new Intent(this, MapsActivity.class);
                intent.putExtra("next", MapsActivity.MAP_BS_HERE);
                startActivity(intent);
        }
    }

    public void siteData(Cursor cursor) {
        if (cursor == null) {
            Toast.makeText(this, "Ошибка", Toast.LENGTH_SHORT).show();
            Log.v("aaa", "Ошибка в Курсоре ");
            return;
        }
        int count;
        count = cursor.getCount();
        Log.v("aaa", "Пришло Количество строк совпадений = " + count);

        switch (count) {
            case 0:
                Toast.makeText(this, "Совпадений не найдено", Toast.LENGTH_LONG).show();
                break;
            case 1:
                toSiteInfo(cursor);
                break;
            default:
                if (count > 40) {
                    Toast.makeText(this, "Слишком много совпадений. Уточните запрос", Toast.LENGTH_SHORT).show();
                    break;
                } else {
                    if (count > 1) {
                        toSiteChoice(cursor, count);
                        Toast.makeText(this, "Количество  совпадений = " + count, Toast.LENGTH_SHORT).show();
                        Log.v("aaa", "Много совпадений сайтов");
                        break;
                    } else {
                        Toast.makeText(this, "Ошибка", Toast.LENGTH_SHORT).show();
                        break;
                    }
                }
        }
        Log.v("aaa", "Конец siteData");
    }

    public void toSiteInfo(Cursor cursor) {
        if (cursor == null) Log.v("aaa", "NULL -1");
        cursor.moveToFirst();
        double lat, lng;
        String[] headers = getResources().getStringArray(R.array.columns);
        String[] text = new String[headers.length];
        Log.v("aaa", "headers.length " + headers.length);
        Log.v("aaa", "text.length " + text.length);
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

        Log.v("aaa", " SITE  ==" + site);
        Log.v("aaa", "lat  ==" + lat);
        Log.v("aaa", "lng  ==" + lng);
        cursor.close();
        Log.v("aaa", "Вся БД закрылась-2");
        Intent intent = new Intent(this, SiteInfo.class);
        intent.putExtra("lines", text);
        intent.putExtra("lat", lat);
        intent.putExtra("lng", lng);
        intent.putExtra("site", site);
        startActivity(intent);
    }

    public void toSiteChoice(Cursor cursor, int count) {
        if (cursor == null) Log.v("aaa", "NULL-10");
        cursor.moveToFirst();
        String[] headers = getResources().getStringArray(R.array.columnsChoice);
        String[] param1 = new String[count];
        String[] param2 = new String[count];
        String[] id = new String[count];
        Log.v("aaa", "Choice.headers.length " + headers.length);
        for (int i = 0; i < count; i++) {
            param1[i] = cursor.getString(cursor.getColumnIndex(headers[0]));
            param2[i] = cursor.getString(cursor.getColumnIndex(headers[1]));
            id[i] = cursor.getString(cursor.getColumnIndex("_id"));
            Log.v("aaa", i + "id[i] " + id[i]);
            Log.v("aaa", i + "param1[i] " + param1[i]);
            Log.v("aaa", i + "param2[i] " + param2[i]);
            cursor.moveToNext();
        }
        cursor.close();
        Intent intent = new Intent(this, SiteChoice.class);
        intent.putExtra("param1", param1);
        intent.putExtra("param2", param2);
        intent.putExtra("id", id);
        startActivity(intent);
    }
}