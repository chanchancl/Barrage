

//! zinc
library BehaviorDemo requires BarrageBase{

	real BehaviorFuncAddSpeed = 10;
	public function AddSpeed(Barrage b)
	{
		real len = SquareRoot(b.vx*b.vx+b.vy*b.vy);
		b.vx = b.vx*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/len);
		b.vy = b.vy*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/len);
		//print("BehaviorFuncAddSpeed.vx : " + R2S(b.vx));
		//print("BehaviorFuncAddSpeed.vy : " + R2S(b.vy));
	}

	real BehaviorFuncRotateAngel = 90;
	//Positive values for the counter clockwise rotation,旋转速度方向
	real BehaviorFuncRotateSpeed = 500;
	public function Rotate(Barrage b)
	{
		real dvx,dvy;
		real len;
		len = SquareRoot(b.vx*b.vx + b.vy*b.vy);
		dvx = BehaviorFuncRotateSpeed * UPDATA_TICK * ((b.vx*CosBJ(BehaviorFuncRotateAngel) - b.vy*SinBJ(BehaviorFuncRotateAngel))/len);
		dvy = BehaviorFuncRotateSpeed * UPDATA_TICK * ((b.vx*SinBJ(BehaviorFuncRotateAngel) + b.vy*CosBJ(BehaviorFuncRotateAngel))/len);
		b.vx += dvx;
		b.vy += dvy;
	}
}



library BarrageTest requires BehaviorDemo,BarrageBase{

	integer OnTimerIndex =0;
	function OnTimer()
	{
		real speed;
		real vx,vy;
		Barrage b;
		BarrageUtils bu = GetTimerData(GetExpiredTimer());

		if (bu.BarrageCount >= 300)
		{
			ReleaseTimer(GetExpiredTimer());
			return;
		}

		OnTimerIndex+=1;

		/*if (ModuloInteger(OnTimerIndex,2) == 0)
			return;*/

		speed = 300;

		vx = speed * CosBJ(I2R(OnTimerIndex*3));
		vy = speed * SinBJ(I2R(OnTimerIndex*3));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint),vx,vy,'e000',0);
		//print("                    CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);

		vx = speed * CosBJ(I2R(OnTimerIndex*5));
		vy = speed * SinBJ(I2R(OnTimerIndex*5));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint)-100,vx,vy,'e001',0);
		//print("                    CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);

		vx = speed * CosBJ(I2R(OnTimerIndex*7));
		vy = speed * SinBJ(I2R(OnTimerIndex*7));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint)-200,vx,vy,'e000',0);
		//print("                    CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);

		/*vx = speed * CosBJ(I2R(OnTimerIndex*10));
		vy = speed * SinBJ(I2R(OnTimerIndex*10));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint)-300,vx,vy,'e001',0);
		//print("                    CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);

		vx = speed * CosBJ(I2R(OnTimerIndex*-15));
		vy = speed * SinBJ(I2R(OnTimerIndex*-15));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint)-400,vx,vy,'e000',0);
		//print("                    CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);*/
	}


	
	function tCreateBarrage(BarrageUtils bu){
		timer t;
		t = NewTimer();
		SetTimerData(t,bu);
		TimerStart(t,UPDATA_TICK,true,function OnTimer);

		t=null;
	}

	function onInit() {	
		Behavior b1,b2;
		BarrageUtils bu;
		BarrageManager bm;

		b1 = Behavior.create(0,9999,true);
		b1.AddBehaviorFunc(AddSpeed);
		//b1.AddBehaviorFunc(Rotate);

		/*b2 = Behavior.create(3,9999,false);
		b2.AddBehaviorFunc(Rotate);*/

		bu = BarrageUtils.create();
		bu.AddBehavior(b1);
		bu.AddBehavior(b2);
		tCreateBarrage(bu);

		bm = BarrageManager.create();
		bm.AddBarrageUtils(bu);
		bm.Start();

	}


}


//! endzinc

