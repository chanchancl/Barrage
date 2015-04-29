//! zinc
library BarrageBase requires TimerUtils,Table, Tool{
	/*
		Barrage
			BarrageUtils
			BarrageBehaviours
		BarrageManager
		
	*/

	public rect GameRect ;
	public constant location BarrageStartPoint = Location(-776.3,1287.4);
	public constant real UPDATA_TICK = 0.03;

	public integer BarrageUpdataCount=0;
	public integer DoBehaviorCount=0;
	public integer UtilsUpdataCount=0;
	public integer ManagerUpdataCount=0;


	interface infBarrage{
		real x,y, vx,vy;
		//real speed,angel; //use speed and angel to make unit move
		real f;
		unit u;
		boolean enable;
		boolean alive;
		
		
	}

	public struct Barrage extends infBarrage{
		static method create(real x, real y, real vx, real vy, integer utype, real face) -> thistype{
			thistype temp = thistype.allocate();
			temp.x = x;
			temp.y = y;
			temp.vx = vx;
			temp.vy = vy;
			temp.u = CreateUnit(Player(0), utype, x, y, face);
			YDWEFlyEnable(temp.u);
			SetUnitFlyHeight(temp.u,40,0);
			temp.f = face;
			//默认显示且存活
			temp.enable = true;
			temp.alive = true;
			
			return temp;
		}
		
		public method UpData(real TimeHavePass) -> boolean {
			BarrageUpdataCount+=1;
			this.Move();
			
			if(!IsEnable())
				return false;

			//print("Barrage" + I2S(this) + "is UpData");

			//print("Barrage.u.x:" + R2S(GetUnitX(this.u)));
			//print("Barrage.u.y:" + R2S(GetUnitY(this.u)));
			//print("GameRect.GetRectMinX: " + R2S(GetRectMinX(GameRect)));
			//print("GameRect.GetRectMaxX: " + R2S(GetRectMaxX(GameRect)));
			//print("GameRect.GetRectMinY: " + R2S(GetRectMinY(GameRect)));
			//print("GameRect.GetRectMaxY: " + R2S(GetRectMaxY(GameRect)));
				
				
			if( RectContainsUnit(GameRect, this.u) == false){

				/*print("BarrageId: " + I2S(this) + " is out of rect,will be dead.");
				print("Barrage.u.x:" + R2S(GetUnitX(this.u)));
				print("Barrage.u.y:" + R2S(GetUnitY(this.u)));
				print("GameRect.GetRectMinX: " + R2S(GetRectMinX(GameRect)));
				print("GameRect.GetRectMaxX: " + R2S(GetRectMaxX(GameRect)));
				print("GameRect.GetRectMinY: " + R2S(GetRectMinY(GameRect)));
				print("GameRect.GetRectMaxY: " + R2S(GetRectMaxY(GameRect)));*/

				this.SetEnable(false);
				this.alive = false;
				KillUnit(this.u);
				return false;
			}
			//print("Barrage" + I2S(this) + "is UpData over");
			
			return true;
		}
		
		method IsEnable() -> boolean { return this.enable;}
		method IsAlive() -> boolean 
		{ 
			this.alive = IsUnitAliveBJ(this.u);
			return this.alive;
		}
		method SetEnable(boolean b){
			ShowUnit(this.u, b);
			this.enable = b;
		}
		
		method Move(){
			x += vx * UPDATA_TICK;
			y += vy * UPDATA_TICK;
			
			SetUnitX(u,x);
			SetUnitY(u,y);
			SetUnitFacing(u,f);
		}

		method destroy(){
			RemoveUnit(this.u);
			this.u=null;
			this.deallocate();
		}
	}

	type BehaviorFunc extends function(Barrage);

	public struct Behavior
	{
		real StartTime;
		real EndTime;
		real CreateTime;
		boolean AbsoluteTime;
		BehaviorFunc FuncList[1000];
		integer FuncCount;


		static method create(real StartTime,real EndTime, boolean AbsoluteTime,real CreateTime) ->thistype{
			thistype temp = thistype.allocate();
			temp.StartTime = StartTime;
			temp.EndTime = EndTime;
			temp.AbsoluteTime = AbsoluteTime;
			temp.CreateTime = CreateTime;
			temp.FuncCount = 0;

			return temp;
		}

		method DoBehavior(Barrage b)
		{
			integer i;
			DoBehaviorCount+=1;

			for (i = 0; i < FuncCount; i+=1)
				FuncList[i].evaluate(b);
		}

		public method AddBehaviorFunc(BehaviorFunc fun){
			FuncList[FuncCount] = fun;
			FuncCount+=1;
		}

		public method Suit(real TimeHavePass) -> boolean{


			if(AbsoluteTime){
				if (TimeHavePass >= StartTime && TimeHavePass <= EndTime){
					return true;
				}
				else { return false; }
			}
			else{
				if ((TimeHavePass-CreateTime) >= StartTime && (TimeHavePass-CreateTime) <= EndTime ){
					return true;
				}
					
				else{return false;}
			}


		}
	}
	

	public struct BarrageUtils{
		static  integer BARRAGE_ROOT  = 10000000;
		static  integer BEHAVIOU_ROOT = 1000;
		integer BarrageCount;
		integer BehaviorCount;

		static Table DataTable;

		method UpData(real TimeHavePass)
		{
			integer i,k;
			Barrage b;
			Behavior be;

			UtilsUpdataCount+=1;
			
			//print("BarrageUtils.UpData");
			for(i=0; i< this.BarrageCount; i+=1){
				b = this.GetBarrage(i);

				if(b.IsAlive()){
					//print("Barrage" + I2S(b) + "is alive");
					b.UpData(TimeHavePass);
					if (b.IsAlive())
					{
						// TODO Behavior
						for (k = 0; k < BehaviorCount; k+=1) {
							be = GetBehavior(k);
							if(be.Suit(TimeHavePass)){
								//print( "i =  " + I2S(i) +"  Behavior" + I2S(be) + "is suit for Barrage : " + I2S(b));
								be.DoBehavior(b);
							}
						}
							
					}
					else
					{
						SetBarrage(i,GetBarrage(BarrageCount-1));
						//SetBarrage(BarrageCount, -1);
						BarrageCount-=1;
						b.destroy();
						i-=1;
					}
				}
			}
		}

		method IsAlive() ->boolean {
			integer i;
			for (i = 0; i < BarrageCount; i+=1)
			{
				if (GetBarrage(i).IsAlive())
				{
					return true;
				}
			}
			return false;
		}
		
		method AddBarrage(Barrage added){
			DataTable[this*BARRAGE_ROOT + BarrageCount] =  added;
			BarrageCount+=1;
		}
		method GetBarrage(integer id) -> Barrage{
			return DataTable[this*BARRAGE_ROOT + id];
		}

		method SetBarrage(integer id,Barrage b){
			DataTable[this*BARRAGE_ROOT + id] = b;
		}

		method AddBehavior(Behavior added){
			DataTable[this*BEHAVIOU_ROOT + BehaviorCount] = added;
			BehaviorCount+=1;
		}

		method GetBehavior(integer id) -> Behavior{
			return DataTable[this*BEHAVIOU_ROOT + id];
		}

		method SetBehavior(integer id, Behavior b){
			DataTable[this*BEHAVIOU_ROOT + id] = b;
		}
		
		static method onInit(){
			DataTable = Table.create();
		}
	}
	
	public struct BarrageManager {
		BarrageUtils UtilsList[1000];
		public integer BarrageUtilsCount;
		public integer UpdataCount;


		static method UpData(){
			integer i;
			BarrageUtils bu;
			BarrageManager this = GetTimerData(GetExpiredTimer());

			ManagerUpdataCount+=1;
			//print("Manager.UpData");
			for(i=0;i<BarrageUtilsCount;i+=1){
				bu = this.UtilsList[i];
				if (bu.IsAlive()){
					//print("Manager.Utils is alive");
					bu.UpData(I2R(UpdataCount)*UPDATA_TICK);
					//print("BarrageCount : " + I2S(bu.BarrageCount) );
				}
			}

			if (I2R(UpdataCount)*UPDATA_TICK > 1.0)
			{
				print("---------------------------------------------------------------------");
				print("Barrage.Update called : " + R2S(I2R(BarrageUpdataCount)/(I2R(UpdataCount)*UPDATA_TICK)) + "  times per second."  );
				print("Behavior.DoBehavior called : " + R2S(I2R(DoBehaviorCount)/(I2R(UpdataCount)*UPDATA_TICK)) + "  times per second."  );
				print("Utils.Update called : " + R2S(I2R(UtilsUpdataCount)/(I2R(UpdataCount)*UPDATA_TICK)) + "  times per second."  );
				print("Manager.Update called : " + R2S(I2R(ManagerUpdataCount)/(I2R(UpdataCount)*UPDATA_TICK)) + "  times per second."  );
			}
			


			UpdataCount+=1;
		}

		method AddBarrageUtils(BarrageUtils bu)
		{
			UtilsList[BarrageUtilsCount] = bu;
			BarrageUtilsCount += 1;
		}

		method Start()
		{
			timer t;
			t = NewTimer();
			SetTimerData(t,this);
			TimerStart(t,UPDATA_TICK,true,function thistype.UpData);
			t=null;
		}
		
	}

	function onInit(){
		GameRect = Rect(-1344,-192,-160,1472);
	}
}

//! endzinc
