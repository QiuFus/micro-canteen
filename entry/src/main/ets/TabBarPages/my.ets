import { curves } from "@kit.ArkUI"
import { WsSendMessage } from "../pages/main"
import { emitter } from "@kit.BasicServicesKit"
import { pictureService } from "../utils/PictureService";
import { myserverurl } from "../LoginBranch/Page";
import { notificationPage } from "../MyPageBranch/notificationPage";
import { AddOrDelete } from "../MyPageBranch/addOrDelete";
import { MyLikes } from "../MyPageBranch/MyLikes";
import { setFoods } from "../MyPageBranch/setFoods";
import { qfsGet, qfsPut } from "../utils/httpRequest";
import { myInfoPage } from "../MyPageBranch/myInfoPage";

const WSMESSAGE_EVENT_ID = 1;
export interface gndata{
  name:string
  toname:string
  id:number
  icon:Resource
}
class mydata {
  username: string = '';
  nickname: string = '我';
  avatar_url: string = '';
  role: string = '';
}
interface reqData{
  code:number
  msg: string
  data:mydata[]
}

@Component
export struct My {
  @Consume('NavPathStack') pageState:NavPathStack

  @State showset:boolean=false
  @StorageLink('requestCount') requestCount: number = 0
  @StorageLink('notificationNum') notificationNum: number = 0
  @State myData: mydata = new mydata();
  @State showUtilIndex:number=-1

  private postdata:gndata[]=[
    {name:'饭搭子',toname:'addOrDelete',id:0,icon:$r('sys.symbol.children')},
    {name:'通知',toname:'',id:1,icon:$r('sys.symbol.bell_fill')},
    {name:'喜欢',toname:'',id:2,icon:$r('sys.symbol.heart_fill')},
    {name:'我发布的',toname:'',id:3,icon:$r('sys.symbol.arrow_up_circle_fill')},
    {name:'设置',toname:'',id:4,icon:$r('sys.symbol.gearshape')}
  ]
  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    if (envelope.type === 'updata_avatar') {
      const newAvatar= envelope.payload as Record<string,string>
      this.myData.avatar_url=newAvatar.avatar_url
    }

  };

  aboutToAppear(): void {
    this.getMyData()
    this.getUIContext()?.animateTo({
      curve:curves.springMotion(0.6,0.7)
    },()=>{
      this.showset=!this.showset
    })
    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }

  async setAvatar(){
    try {
      const url=await pictureService.selectAndUpload(`http://${myserverurl}:8080/upload`)
      await qfsPut(`set/avatar/${url}`)
    }catch (err){
      console.warn('[ztwjj]头像put失败',err.message)
    }
  }

  async getMyData(){
    const result=await qfsGet(`get/myData`) as reqData
    this.myData=result.data[0]
  }

  @Builder
  unReadData(num:number){
    Row(){
      Text(num>=99?'99+':num+'')
        .fontColor(Color.White)
        .margin({left:5,right:5})
    }
    .justifyContent(FlexAlign.Center)
    .constraintSize({minWidth:20})
    .height(20)
    .borderRadius(20)
    .backgroundColor(Color.Red)
  }

  build() {
      if (this.showUtilIndex==-1) {
        Column({ space: 20 }) {
          if (this.showset) {
            Column() {
              Stack(){
                Image($r('app.media.userimg'))
                  .size({ width: 100, height: 100 }).borderRadius(100)
                Image(this.myData.avatar_url==''?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${this.myData.avatar_url}`)
                  .size({ width: 100, height: 100 })
                  .borderRadius(100)
                  .onClick(async () => {
                    this.setAvatar()
                  })
              }

              Text(this.myData.nickname)
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 20 })
            }
            .transition(TransitionEffect.OPACITY.animation({ curve: curves.springMotion(1, 0.8) })
              .combine(TransitionEffect.translate({ y: -50 }))
            )
          }
          if (this.showset) {
            Column() {
              ForEach(this.postdata, (item: gndata) => {
                Row({ space: 10 }) {
                  SymbolGlyph(item.icon)
                    .fontSize(30)
                    .fontColor(['#ffa7a7a7'])
                  Text(item.name)
                    .fontSize(20)
                  Blank()
                  if (item.name == '饭搭子' && this.requestCount > 0) {
                    this.unReadData(this.requestCount)
                  } else if (item.name == '通知' && this.notificationNum > 0) {
                    this.unReadData(this.notificationNum)
                  }
                }
                .width('90%')
                .padding(20)
                .borderRadius(5)
                .margin({ top: 14 })
                .backgroundColor(Color.White)
                .visibility((this.myData.role=='student' && item.name=="我发布的")?Visibility.None:Visibility.Visible)
                .geometryTransition(`utielId${item.id}`,{ follow:false})
                .onClick(() => {
                  this.getUIContext()?.animateTo({
                    curve: curves.springMotion(0.4, 0.58)
                  }, () => {
                    this.showUtilIndex = item.id
                  })
                })
              })
            }
            .size({width:'100%',height:'70%'})
            .transition(TransitionEffect.OPACITY
              .combine(TransitionEffect.translate({ y: 50 }))
            )
          }
        }
        .padding({ top: 20 })
        .backgroundColor('#ffe7e7e7')
        .height('100%')
        .width('100%')
      }else if (this.showUtilIndex==0) {
        AddOrDelete({showMe:this.showUtilIndex})
      }
      else if(this.showUtilIndex==1){
        notificationPage({showMe:this.showUtilIndex})
      }else if (this.showUtilIndex==2) {
        MyLikes({showMe:this.showUtilIndex})
      }else if (this.showUtilIndex==3) {
        setFoods({showMe:this.showUtilIndex})
      }else if(this.showUtilIndex==4){
        myInfoPage({showMe:this.showUtilIndex,nickname:this.myData.nickname})
      }
  }
}