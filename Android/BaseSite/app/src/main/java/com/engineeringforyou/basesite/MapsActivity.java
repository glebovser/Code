package com.engineeringforyou.basesite;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.UiSettings;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import static android.location.LocationManager.PASSIVE_PROVIDER;

public class MapsActivity extends AppCompatActivity implements OnMapReadyCallback, GoogleMap.OnInfoWindowClickListener, GoogleMap.OnMapLongClickListener {

    static final int MAP_BS_HERE = 1;
    static final int MAP_BS_SITE = 2;
    static final int MAP_BS_ONE = 3;
    static float radius = 3; // ралиус "квадрата" в километрах
    private final float SCALE_BASIC = 15;
    private GoogleMap mMap;
    double lat, lng;
    String siteNumber;
    private UiSettings mUiSettings;
    int nextStep;
    private boolean mLocationPermissionGranted;
    private static final int PERMISSIONS_REQUEST_ACCESS_FINE_LOCATION = 1;
    private static final String APP_PREFERENCES = "mysettings";
    private static final String APP_PREFERENCES_COUNTER = "radius";
    private SharedPreferences mSettings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.v("aaa", "onCreate MapsActivity ");
        mSettings = getSharedPreferences(APP_PREFERENCES, Context.MODE_PRIVATE);
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            nextStep = extras.getInt("next");
            lat = extras.getDouble("lat");
            lng = extras.getDouble("lng");
            siteNumber = extras.getString("site");
        }
        setContentView(R.layout.activity_maps);
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_map, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        switch (id) {
            case R.id.action_radius:
                new DialogRadius().show(getFragmentManager(), "dialog");
//Подождать заершения диалога
//                mMap.clear();
//                fillMap();
                return true;
            case R.id.operators:
                Toast.makeText(this, "Пока не реализовано, но Алексей уже работает над этим", Toast.LENGTH_SHORT).show();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        SharedPreferences.Editor editor = mSettings.edit();
        editor.putFloat(APP_PREFERENCES_COUNTER, radius);
        editor.apply();
        Log.v("aaa", "Запись радиуса в настройки:  " + radius);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mSettings.contains(APP_PREFERENCES_COUNTER)) {
            radius = mSettings.getFloat(APP_PREFERENCES_COUNTER, 1);
            Log.v("aaa", "Радиус из насторек:  " + radius);
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setOnInfoWindowClickListener(this);
        mMap.setOnMapLongClickListener(this);
        mUiSettings = mMap.getUiSettings();
        mUiSettings.setZoomControlsEnabled(true);
        mUiSettings.setCompassEnabled(true);
        getLocationPermission();
        if (mLocationPermissionGranted) {
            mMap.setMyLocationEnabled(true);
        }
        fillMap();
    }

    private void fillMap() {
        switch (nextStep) {
            case MAP_BS_HERE:
                Location location = null;
                if (mLocationPermissionGranted) {
                    LocationManager locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
                    location = locationManager.getLastKnownLocation(PASSIVE_PROVIDER);
                }
                if (location != null) {
                    double latitude = location.getLatitude();
                    double longitude = location.getLongitude();
                    LatLng myPosition = new LatLng(latitude, longitude);
                    mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(myPosition, SCALE_BASIC));
                    Log.v("aaa", "Текущие координаты:  " + latitude + "  " + longitude);

                    checkBS(myPosition);
                } else {
                    Toast.makeText(this, "Ошибка определения местоположения", Toast.LENGTH_SHORT).show();
                    LatLng Position = new LatLng(50.795900, 42.004491);
                    mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(Position, SCALE_BASIC));
                }
                break;

            case MAP_BS_SITE:
                checkBS(new LatLng(lat, lng));

            case MAP_BS_ONE:
                LatLng site = new LatLng(lat, lng);
                mMap.addMarker(new MarkerOptions().position(site).title(siteNumber));
                mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(site, SCALE_BASIC));
        }
    }

    private void checkBS(LatLng center) {
        DBHelper db;
        Cursor userCursor;
        SQLiteDatabase sqld;
        String query;
        String DB_NAME = DBHelper.DB_NAME;

        double latMax,
                latMin,
                lngMax,
                lngMin,
                latDelta,
                lngDelta;

        lat = center.latitude;
        lng = center.longitude;
        latDelta = radius / 111;
        lngDelta = radius / 63.2;
        latMax = lat + latDelta;
        latMin = lat - latDelta;
        lngMax = lng + lngDelta;
        lngMin = lng - lngDelta;
        query = "SELECT * FROM " + DB_NAME + " WHERE GPS_Latitude>" + latMin + " AND GPS_Latitude<" + latMax +
                " AND GPS_Longitude>" + lngMin + " AND GPS_Longitude<" + lngMax;
        Log.v("aaa", "Запрос= " + query);
        // Работа с БД
        db = new DBHelper(this);
        db.create_db();
        sqld = db.open();
        userCursor = sqld.rawQuery(query, null);
        db.close();
        int count = userCursor.getCount();
        Log.v("aaa", "Количество ТОЧЕК совпадения = " + count);

        if (count == 0) {
            Toast.makeText(this, "Здесь БС не найдено!", Toast.LENGTH_SHORT).show();
        } else {
            for (int i = 0; i < count; i++) {
                userCursor.moveToPosition(i);
                mMap.addMarker(new MarkerOptions().
                        position(new LatLng(
                                userCursor.getDouble(userCursor.getColumnIndex("GPS_Latitude")),
                                userCursor.getDouble(userCursor.getColumnIndex("GPS_Longitude")))).
                        title(userCursor.getString(userCursor.getColumnIndex("SITE"))).
                        alpha(0.5f).
                        icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)));
            }
        }
        userCursor.close();
    }

    private void getLocationPermission() {
        if (ContextCompat.checkSelfPermission(this.getApplicationContext(),
                android.Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            mLocationPermissionGranted = true;
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION},
                    PERMISSIONS_REQUEST_ACCESS_FINE_LOCATION);
        }
    }

    @Override
    public void onInfoWindowClick(Marker marker) {
        siteData(new DBHelper(getApplicationContext()).
                siteSearch(marker.getTitle(), 1));
    }

    private void siteData(Cursor cursor) {
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
                if (count > 1) {
                    Toast.makeText(this, "Количество  совпадений = " + count, Toast.LENGTH_SHORT).show();
                    Log.v("aaa", "default");
                    break;
                } else {
                    Toast.makeText(this, "Ошибка", Toast.LENGTH_SHORT).show();
                }
        }
    }

    private void toSiteInfo(Cursor cursor) {

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
        Log.v("aaa", "SITE  ==" + site);
        cursor.close();
        Log.v("aaa", "Вся БД закрылась-2");
        Intent intent = new Intent(this, SiteInfo.class);
        intent.putExtra("lines", text);
        intent.putExtra("lat", lat);
        intent.putExtra("lng", lng);
        intent.putExtra("site", site);
        startActivity(intent);
    }

    @Override
    public void onMapLongClick(final LatLng latLng) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Искать БС в этом месте?");
        builder.setNegativeButton("Нет",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });
        builder.setPositiveButton("Да", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                mMap.clear();
                checkBS(latLng);
            }
        });
        AlertDialog alert = builder.create();
        alert.show();
    }
}
