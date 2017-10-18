package com.engineeringforyou.basesite;

import android.app.DialogFragment;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;
import android.widget.TextView;


/**
 * Created by Сергей on 08.10.2017.
 */

 public class DialogRadius extends DialogFragment implements SeekBar.OnSeekBarChangeListener, View.OnClickListener {
    SeekBar seekBar;
    TextView txt;
    int progress;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        getDialog().setTitle("Выберите радиус (км)");
        View v = inflater.inflate(R.layout.activity_dialog_radius, null);
        v.findViewById(R.id.radiusOk).setOnClickListener(this);
        seekBar = v.findViewById(R.id.seekRadius);
        seekBar.setMax(6);
        seekBar.setProgress((int) MapsActivity.radius-1);
        seekBar.setOnSeekBarChangeListener(this);

        txt = v.findViewById(R.id.textView);
        txt.setText(String.valueOf(seekBar.getProgress()+1));
        return v;
    }

    @Override
    public void onClick(View view) {
        Log.d("aaa", "DialogRadius onClick");
        MapsActivity.radius = seekBar.getProgress()+1;
        dismiss();
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
        progress = seekBar.getProgress();
        txt.setText(String.valueOf(progress+1));
        Log.d("aaa", "progress = " + progress+1);
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
    }
}
