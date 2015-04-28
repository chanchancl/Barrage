//! zinc



library BehaviorDemo requires BarrageBase
{
	real BehaviorFuncAddSpeed = 100;
	public function AddSpeed(Barrage b)
	{
		real len = SquareRoot(b.vx*b.vx+b.vy*b.vy);
		b.vx = b.vx*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/l);
		b.vy = b.vy*(1+ BehaviorFuncAddSpeed*UPDATA_TICK/l);
	}

	real BehaviorFuncRotateAngel = 90;
	//Positive values for the counter clockwise rotation,旋转速度方向
	public function Rotate(Barrage b)
	{
		real x,y;
		x = b.vx*CosBJ(BehaviorFuncRotateAngel) - b.vy*SinBJ(BehaviorFuncRotateAngel);
		y = b.vx*SinBJ(BehaviorFuncRotateAngel) + b.vy*CosBJ(BehaviorFuncRotateAngel);
		b.vx = x;
		v.vy = y;
	}

}

library UtilsDemo requires BarrageBase,BehaviorDemo
{


}


library BarrageTest requires UtilsDemo,BehaviorDemo,BarrageBase
{



}


//! endzinc