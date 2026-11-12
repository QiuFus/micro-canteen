import {FriendList,friendList,friendData}from '../TabBarPages/friendList'
import {myserverurl} from "../LoginBranch/Page"
import {My}from '../TabBarPages/my'
import { MainBility } from '../TabBarPages/mainBility'
import { wsManager } from '../utils/WebSocketManager'
import { emitter } from '@kit.BasicServicesKit'
import { commentType } from '../MainBranch/gotoDetailPage'
import { qfsGet } from '../utils/httpRequest'


const WSMESSAGE_EVENT_ID = 1;

interface tablist{
  text: string
  icon: Resource
  seleicon: Resource
}
interface UnreadBadgePayload{
  conversations: object
  totalUnreadCount: number
}
export interface WsSendMessage{
  type: string
  payload: UnreadBadgePayload|reqnum|updata|Record<string,string>|Record<string,number>
}
export interface reqnum{
  count:number
}
export interface updata{
  friendList:friendList[]
}
export interface requestitem{
  user_id:number
  nickname:string
  avatar_url:string
  friendship_id:number
}
export interface requestData{
  code:number
  msg: string
  data:requestitem[]|notificationType[]|putfoodType[]|setFoodDetailType|getTtype[]
}
export interface notificationType{
  user_id:number
  type:string
  payload:commentType
  created_at:string
  merged_count:number
  is_read:number
  notification_id:number
}
export interface putfoodType{
  food_id: number
  name: string
  image_url: string
  created_at: string
}
export class setFoodDetailType{
  province:string= ""
  city:string= ""
  district:string= ""
  school_name:string= ""
  s_img:string= ""
  school_id:number= 0
  c_name:string= ""
  c_img:string=""
  c_description: string=""
  canteen_id: number=0
  w_name: string= ""
  w_img: string= ""
  w_description: string= ""
  workshop_id: number=0
  f_name: string= ""
  f_img: string= ""
  f_description:string= ""
  food_id: number=0
}
export class getTtype{
  workshop_id: number=-1
  w_name: string=''
  created_at: string=''
  c_name: string=''
  school_name: string=''
}
interface nonum{ ctn:number }

@Entry
@Component
struct Main {
  @Provide('NavPathStack')
  pageState:NavPathStack=new NavPathStack()
  @StorageLink('requestCount') requestCount: number = 0
  @StorageLink('notificationNum') notificationNum: number = 0
  @State totalUnreadCount: number = 0
  @State friendList:friendList[]=[]

  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    switch (envelope.type){
      case 'unread_badge':{
        const val=envelope.payload as UnreadBadgePayload
        this.totalUnreadCount =val.totalUnreadCount
        break;
      }
      case 'friend_request_changed':{
        const val=envelope.payload as reqnum
        this.requestCount=val.count
        break;
      }
      case 'notification_num':{
        const val=envelope.payload as Record<string,number>
        this.notificationNum=val.cnt
        break;
      }
      default :{
        break;
      }
    }
  };

  aboutToAppear(): void {

    const token = AppStorage.get('authToken') as string;
    if (token && token.length > 0) {
        wsManager.init(`ws://${myserverurl}:8080/ws?token=${encodeURIComponent(token)}`);
    } else {
      console.warn('[ztwjj]未登录，无法建立 WebSocket');
    }
    this.showpage()
    this.getrequestlist()
    this.getNotification()
    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }

  //获取未读通知总数
  async getNotification(){
    try {
      const result=await qfsGet(`notification/num`) as nonum
      this.notificationNum=result.ctn
      console.warn('[ztwjj]获取未读通知成功：',result.ctn)
    }catch (err){
      console.warn('[ztwjj]获取未读通知失败：',err)
    }

  }

  //计算显示更新未读消息总数
  async showpage(){
    const result=await qfsGet(`friend/List/main`) as friendData
    this.friendList=result.data
    let allcount=0
    for (let i = 0; i < this.friendList.length; i++) {
      allcount+=this.friendList[i].unread_count ||0
    }
    this.totalUnreadCount=allcount
  }


  //获取并储存好友申请数
  async getrequestlist(){
    const result=await qfsGet(`add/me`) as requestData
    const requestCount=(result.data as requestitem[]).length
    AppStorage.setOrCreate('requestCount',requestCount)
  }


  @State navINdx:number=0
  private tabList:tablist[] = [
    {text: '首页', icon: $r('sys.symbol.house'), seleicon:$r('sys.symbol.house_fill')},
    {text: '消息', icon: $r('sys.symbol.envelope_fill'), seleicon:$r('sys.symbol.envelope_open_fill')},
    {text: '我的', icon: $r('sys.symbol.person'), seleicon:$r('sys.symbol.person_crop_circle_fill_1')}
  ];


  @Builder
  NavMap(){
    if (this.navINdx==0) {
      MainBility()
    }else if(this.navINdx==1){
      FriendList()
    }else if(this.navINdx==2){
      My()
    }
  }

  @Builder
  navTabBar(){
    Row(){
      ForEach(this.tabList,(item:tablist,index)=>{
        Column(){
          Stack({alignContent:Alignment.TopEnd}){
            SymbolGlyph(this.navINdx==index?item.seleicon:item.icon)
              .fontSize(40)
              .fontColor([this.navINdx==index? '#ff87ab09' : '#ff707070'])
              .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP),this.navINdx==index)
            if (this.totalUnreadCount>0 && index==1) {
              Row(){
                Text(this.totalUnreadCount>=99?'99+':this.totalUnreadCount+'')
                  .fontColor(Color.White)
                  .margin({left:5,right:5})
              }
              .position({x:40,y:-10})
              .justifyContent(FlexAlign.Center)
              .constraintSize({minWidth:20})
              .height(20)
              .borderRadius(20)
              .backgroundColor(Color.Red)
            }
            if ((this.requestCount+this.notificationNum)>0 && index==2) {
              Row(){
                Text((this.requestCount+this.notificationNum)>=99?'99+':(this.requestCount+this.notificationNum)+'')
                  .fontColor(Color.White)
                  .margin({left:5,right:5})
              }
              .position({x:30,y:-10})
              .justifyContent(FlexAlign.Center)
              .constraintSize({minWidth:20})
              .height(20)
              .borderRadius(20)
              .backgroundColor(Color.Red)
            }
          }
          Text(item.text)
            .fontColor(this.navINdx==index?'#ff87ab09':'#ff707070')
            .fontSize(18)
        }
        .onClick(()=>{
          this.navINdx=index
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    Navigation(this.pageState){
      this.NavMap()
    }
    .toolbarConfiguration(this.navTabBar(),{backgroundColor:'#fffaf7ed'})
    .height('100%')
    .width('100%')
  }
}

//68dbffbf80e186658a380001e8f304aa03bedf36741d39d40b5676e3d7d9de28