//! zinc
library BarrageBase requires TimerUtils, Vector, ARGB, Table, Tool{
	/*
		Barrage
			BarrageUtils
			BarrageBehaviours
		BarrageManager
		
	*/
	
	rect GameRect = Rect(-1344,-192,-160,1472);
	constant location BarrageStartPoint = Location(-776.3,1287.4);
	constant real UPDATA_TICK = 0.03;

	interface infBarrage{
		real x,y, vx,vy;
		real f;
		unit u;
		boolean enable;
		boolean alive;
		
		
	}

	struct Barrage extends infBarrage{
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
		
		public method UpData() -> boolean {
			this.Move();
			
			if(!IsEnable())
				return false;
				
				
			if( RectContainsUnit(GameRect, this.u) == true){
				print("BarrageId: " + I2S(this) + " is out of rect,will be dead.");
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
	
	integer TempBehaviorIndex = 0;
	public function TempBehavior(Barrage b)
	{
		real a;
		real dax,day,l;
		integer angel=90;
		
		TempBehaviorIndex+=1;
		/*if(TempBehaviorIndex>=30)
		{
			angel = -angel;
			TempBehaviorIndex=0;
		}*/
		
		a=300;
		l = SquareRoot(b.vx*b.vx + b.vy*b.vy);

		dax = a * UPDATA_TICK * ((b.vx*CosBJ(angel) - b.vy*SinBJ(angel))/l);
		day = a * UPDATA_TICK * ((b.vx*SinBJ(angel) + b.vy*CosBJ(angel))/l);

		b.vx += dax;
		b.vy += day;
		
	}
	
	struct BarrageUtils{
		static  integer MAX_BARRAGES = 10000;
		integer BarrageNum;
		static Table BarrageTable;
		
		static method execute(){
			integer i;
			Barrage b;
			BarrageUtils bu = GetTimerData(GetExpiredTimer());
			
			//print("BarrageUtils.execute()" + I2S(bu.BarrageNum));
			
			for(i=0; i< bu.BarrageNum; i+=1){
				b = bu.GetBarrage(i);
				if(b.IsAlive()){
					b.UpData();
					TempBehavior(b);
				}
			}
		}
		
		method Append(Barrage added){
			BarrageTable[this*MAX_BARRAGES + BarrageNum] =  added;
			BarrageNum+=1;
		}
		method GetBarrage(integer id) -> Barrage{
			return BarrageTable[this*MAX_BARRAGES + id];
		}
		
		
		static integer index =1;
		static method actions(){
			BarrageUtils bu = GetTimerData(GetExpiredTimer());
			real TimeHavePass = I2R(index) * UPDATA_TICK;
			real speed = 300;
			real vx,vy;
			integer utype;
			Barrage b;
			
			if(bu.BarrageNum >=360)
			{
				ReleaseTimer(GetExpiredTimer());
				return;
			}
			index+=1;
			utype = 'e000';
			if(ModuloInteger(index,3) == 0){
				utype = 'e001';
			}
			if(ModuloInteger(index,4) == 0){
				return;
			}
			
			//print("actions +  " + I2S(index));

			vx = speed * CosBJ(I2R(bu.BarrageNum*3));
			vy = speed * SinBJ(I2R(bu.BarrageNum*3));
			//print(I2S(bu.BarrageNum*2));
			b = Barrage.create(GetLocationX(BarrageStartPoint),GetLocationY(BarrageStartPoint),vx,vy,utype,0);
			bu.Append(b);
			
		}
		
		static method onInit()
		{	
			BarrageUtils bu ;
			timer t;
			BarrageTable = Table.create();
			
			bu = BarrageUtils.create();
			t = NewTimer();
			SetTimerData(t,bu);
			TimerStart(t,UPDATA_TICK,true,function BarrageUtils.actions);
			t = null;
			
			t= NewTimer();
			SetTimerData(t,bu);
			TimerStart(t,UPDATA_TICK,true,function BarrageUtils.execute);
			t=null;
		}
	}
	
	struct BarrageManage {
		
		
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

//! endzinc
