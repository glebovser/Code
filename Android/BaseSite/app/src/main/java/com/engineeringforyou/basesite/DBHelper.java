package com.engineeringforyou.basesite;

import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;

/**
 * Created by Сергей on 30.09.2017.
 */

  class DBHelper extends SQLiteOpenHelper {
    private static String DB_PATH; // полный путь к базе данных
    private static String DB_NAME1 = "MTS_DataBaseFile.db";
    static String DB_NAME = "MTS_Site_Base";
    private static final int SCHEMA = 1; // версия базы данных
    private Context myContext;

    DBHelper(Context context) {
        super(context, DB_NAME1, null, SCHEMA);
        this.myContext = context;
        DB_PATH = context.getFilesDir().getPath() + DB_NAME1;
        Log.v("aaa", "Создание экземпляра БД");
        Log.v("aaa", "ПУТЬ  к БД = " + DB_PATH);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        Log.v("aaa", "Попытка создать БД");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        Log.v("aaa", "Попытка обновить БД");
    }

    Cursor siteSearch(String siteQuery, int mode) {
        DBHelper db = null;
        Cursor userCursor = null;
        SQLiteDatabase sqld;
        int count = 0;
        if (mode == 1) {
            Log.v("aaa", "Запрос mode 1");
            String query[] = new String[5];
            query[0] = "SELECT * FROM " + DB_NAME + " WHERE SITE = '" + siteQuery + "'";
            query[1] = "SELECT * FROM " + DB_NAME + " WHERE SITE = '77-" + siteQuery + "'";
            query[2] = "SELECT * FROM " + DB_NAME + " WHERE SITE LIKE '77-" + siteQuery + "%'";
            //  query[1] = "SELECT * FROM " + DB_NAME + " WHERE SITE LIKE '77-%" + siteQuery + "'";
            query[3] = "SELECT * FROM " + DB_NAME + " WHERE SITE LIKE '%" + siteQuery + "'";
            query[4] = "SELECT * FROM " + DB_NAME + " WHERE SITE LIKE '%" + siteQuery + "%'";
            Log.v("aaa", query[0]);
            Log.v("aaa", query[1]);
            Log.v("aaa", query[2]);
            Log.v("aaa", query[3]);
            Log.v("aaa", query[4]);
            // Работа с БД
            db = new DBHelper(this.myContext);
            db.create_db();
            sqld = db.open();
            for (String quer : query) {
                Log.v("aaa", "Поиск в курсоре");
                userCursor = sqld.rawQuery(quer, null);
                count = userCursor.getCount();
                if (count != 0) {
                    break;
                }
            }
        } else {
            if (mode == 2) {
                Log.v("aaa", "Запрос mode 2");
                siteQuery = siteQuery.replace(',', ' ');
                String[] words = siteQuery.split(" ");
                Log.v("aaa", Arrays.toString(words));
                StringBuilder query = new StringBuilder();
                // Работа с БД
                db = new DBHelper(this.myContext);
                db.create_db();
                sqld = db.open();
                boolean isFirst = true;
                query.append("SELECT * FROM " + DB_NAME + " WHERE ");
                for (int i = 0; i < words.length; i++) {
                    if (words[i] == " ") continue;
                    if (isFirst) {
                        query.append("ADDRES LIKE ");
                        isFirst = false;
                    } else {
                        query.append("AND ADDRES LIKE ");
                    }
                    query.append("'%" + words[i] + "%'");
                }
                userCursor = sqld.rawQuery(String.valueOf(query), null);
                count = userCursor.getCount();
                Log.v("aaa", "Количество текстовых совпадений = " + count);
            } else {
                if (mode == 3) {
                    Log.v("aaa", "Запрос mode 3");
                    String query;
                    query = "SELECT * FROM " + DB_NAME + " WHERE _ID = " + siteQuery;
                    db = new DBHelper(this.myContext);
                    db.create_db();
                    sqld = db.open();
                    userCursor = sqld.rawQuery(query, null);
                    count = userCursor.getCount();
                    Log.v("aaa", "Количество текстовых совпадений по id = " + count);
                }
            }
        }

        Log.v("aaa", "Количество строк совпадений = " + count);
        db.close();
        // userCursor.close();
        Log.v("aaa", "Вся БД закрылась-3");
        return userCursor;
    }

    void create_db() {
        InputStream myInput = null;
        OutputStream myOutput = null;
        try {
            File file = new File(DB_PATH);
            if (!file.exists()) {
                this.getReadableDatabase();
                //получаем локальную бд как поток
                myInput = myContext.getAssets().open(DB_NAME1);
                // Путь к новой бд
                String outFileName = DB_PATH;
                // Открываем пустую бд
                myOutput = new FileOutputStream(outFileName);
                // побайтово копируем данные
                byte[] buffer = new byte[1024];
                int length;
                while ((length = myInput.read(buffer)) > 0) {
                    myOutput.write(buffer, 0, length);
                }
                myOutput.flush();
                myOutput.close();
                myInput.close();
            }
        } catch (IOException ex) {
            Log.v("aaa", ex.getMessage());
        }
    }

    SQLiteDatabase open() throws SQLException {
        return SQLiteDatabase.openDatabase(DB_PATH, null, SQLiteDatabase.OPEN_READONLY);
    }
}

