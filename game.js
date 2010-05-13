package org.wololo;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;

public class Game extends Activity {
    
	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        
        setContentView(R.layout.main);

        GameView gameView = (GameView) findViewById(R.id.GameView01);

        gameView.gameThread.setState(GameThread.STATE_READY);
        
        gameView.gameThread.newGame();
    }
}