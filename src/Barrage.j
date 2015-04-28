//! zinc
library BarrageBase requires TimerUtils,Table, Tool{
	/*
		Barrage
			BarrageUtils
			BarrageBehaviours
		BarrageManager
		
	*/
public{
	public rect GameRect = Rect(-1344,-192,-160,1472);
	public constant location BarrageStartPoint = Location(-776.3,1287.4);
	public constant real UPDATA_TICK = 0.03;


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
			this.Move();
			
			if(!IsEnable())
				return false;
				
				
			if( RectContainsUnit(GameRect, this.u) == false){
				//print("BarrageId: " + I2S(this) + " is out of rect,will be dead.");
				this.SetEnable(false);
				this.alive = false;
				return false;
			}
			
			return true;
		}
		
		method IsEnable() -> boolean { return this.enable;}
		method IsAlive() -> boolean { return this.alive;}
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
			if (!b.IsAlive())
				return;
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
			
			
			for(i=0; i< this.BarrageCount; i+=1){
				b = this.GetBarrage(i);
				if(b.IsAlive()){
					b.UpData(TimeHavePass);
					// TODO Behavior
					for (k = 0; k < BehaviorCount; k+=1) {
						be = GetBehavior(k);
						if(be.Suit(TimeHavePass))
							be.DoBehavior(b);
					}
				}
			}
		}

		method IsAlive() ->boolean {
			integer i;
			for (i = 0; i < BarrageCount; i+=1)
			{
				if (!GetBarrage(i).IsAlive())
				{
					return false;
				}
			}
			return true;
		}
		
		method AddBarrage(Barrage added){
			DataTable[this*BARRAGE_ROOT + BarrageCount] =  added;
			BarrageCount+=1;
		}
		method GetBarrage(integer id) -> Barrage{
			return DataTable[this*BARRAGE_ROOT + id];
		}

		method AddBehavior(Behavior added){
			DataTable[this*BEHAVIOU_ROOT + BehaviorCount] = added;
			BehaviorCount+=1;
		}

		method GetBehavior(integer id) -> Behavior{
			return DataTable[this*BEHAVIOU_ROOT + id];
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
			for(i=0;i<BarrageUtilsCount;i+=1){
				bu = this.UtilsList[i];
				if (bu.IsAlive()){
					bu.UpData(I2R(UpdataCount)*UPDATA_TICK);
				}
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

		static method onInit()
		{
		}
		
	}
	
	/*function ab()
	{
		Barrage b = GetTimerData(GetExpiredTimer());
		b.UpData();
		TempBehavior(b);
	}

	function onInit(){
		Barrage b;
		real vx,vy;
		timer t;		
		
		vx=135.0;
		vy=-200.0;
		b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint),vx,vy,'e000',0);
		t = NewTimer();
		SetTimerData(t,b);
		TimerStart(t,UPDATA_TICK,true,function ab);
		t=null;
	}*/
}
}

//! endzinc