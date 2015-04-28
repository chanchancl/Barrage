

//! zinc
library BehaviorDemo requires BarrageBase{

	real BehaviorFuncAddSpeed = 100;
	public function AddSpeed(Barrage b)
	{
		real len = SquareRoot(b.vx*b.vx+b.vy*b.vy);
		b.vx = b.vx*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/len);
		b.vy = b.vy*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/len);
	}

	real BehaviorFuncRotateAngel = 90;
	//Positive values for the counter clockwise rotation,旋转速度方向
	public function Rotate(Barrage b)
	{
		real x,y;
		x = b.vx*CosBJ(BehaviorFuncRotateAngel) - b.vy*SinBJ(BehaviorFuncRotateAngel);
		y = b.vx*SinBJ(BehaviorFuncRotateAngel) + b.vy*CosBJ(BehaviorFuncRotateAngel);
		b.vx = x;
		b.vy = y;
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

		if (bu.BarrageCount >= 360)
		{
			ReleaseTimer(GetExpiredTimer());
			return;
		}

		OnTimerIndex+=1;

		if (ModuloInteger(OnTimerIndex,2) == 0)
			return;

		speed = 300;

		vx = speed * CosBJ(I2R(bu.BarrageCount*3));
		vy = speed * SinBJ(I2R(bu.BarrageCount*3));
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint),vx,vy,'e000',0);
		//print("CreateBarrage:" + I2S(b));
		bu.AddBarrage(b);
	}
	
	function tCreateBarrage(BarrageUtils bu){
		timer t;
		t = NewTimer();
		SetTimerData(t,bu);
		TimerStart(t,UPDATA_TICK,true,function OnTimer);
		t=null;
	}

	function onInit() {	
		Behavior BDemo;
		BarrageUtils bu;
		BarrageManager bm;

		BDemo = Behavior.create(0,5,true,0);
		BDemo.AddBehaviorFunc(AddSpeed);
		BDemo.AddBehaviorFunc(Rotate);

		bu = BarrageUtils.create();
		bu.AddBehavior(BDemo);
		tCreateBarrage(bu);

		bm = BarrageManager.create();
		bm.AddBarrageUtils(bu);
		bm.Start();

	}


}


//! endzinc

