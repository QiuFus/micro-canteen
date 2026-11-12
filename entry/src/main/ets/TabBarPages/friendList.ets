import { curves } from "@kit.ArkUI"
import {myserverurl} from "../LoginBranch/Page"
import emitter from '@ohos.events.emitter';
import { formatTimeAgo } from "../utils/DateComparison";
import { qfsGet } from "../utils/httpRequest";

const WSMESSAGE_EVENT_ID = 1;

export interface friendList{
  user_id: number,
  nickname: string,
  avatar_url: string
  is_friend:number
  unread_count:number
  last_message:string
  last_time:string
}

export interface friendData{
  code:number
  msg: string
  data:friendList[]
}

interface UnreadBadgePayload{
  conversations: friendList[]
  totalUnreadCount: number
}
interface WsSendMessage{
  type: string
  payload: UnreadBadgePayload
}

@Component
export struct FriendList {
  @Consume('NavPathStack') pageState:NavPathStack
  @State showScroll:boolean=false
  @State friendList:friendList[]=[]

  private unreadCallback = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    if (envelope.type === 'unread_badge') {
      const badge = envelope.payload as UnreadBadgePayload;
      this.friendList = badge.conversations;
    }
  };

   aboutToAppear(): void {
     this.showpage()
     emitter.on({eventId:WSMESSAGE_EVENT_ID},this.unreadCallback)
  }

  aboutToDisappear(): void {
     emitter.off(WSMESSAGE_EVENT_ID,this.unreadCallback)
  }

  async showpage(){

    const result=await qfsGet(`friend/List/main`) as friendData
    this.friendList=result.data

    setTimeout(()=>{
      this.getUIContext()?.animateTo({
        curve:curves.springMotion(0.4,0.5)
      },()=>{
        this.showScroll=true
      })
    },50)
  }

  toDetail(vo:friendList){
    this.pageState.pushPathByName('userMessage',vo)
  }


  build() {
    Column(){
      Row(){
          Text('饭搭子')
            .fontSize(30)
            .fontColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .height(60)
      .backgroundColor('#ff87ab09')
      .width('100%')
      .padding(10)

      if (this.showScroll){
        List(){
            ForEach(this.friendList,(item:friendList,index)=>{
              ListItem(){
                  Row(){
                    Stack({alignContent:Alignment.TopEnd}){
                      Image(item.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${item.avatar_url}`)
                        .size({width:50,height:50})
                        .borderRadius(5)
                      if (item.unread_count>0) {
                        Row(){
                          Text(item.unread_count>=99?'99+':item.unread_count+'')
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
                    }
                    Column({space:5}){
                      Text(item.nickname)
                        .fontSize(20)
                      Text(item.last_message)
                          .fontColor('#ff7a7a7a')
                          .fontSize(16)
                          .maxLines(1)
                          .constraintSize({maxWidth:'60%'})
                          .textOverflow({overflow:TextOverflow.Ellipsis})
                    }
                    .alignItems(HorizontalAlign.Start)
                    .transition(TransitionEffect.OPACITY)
                    .margin({left:10})

                    Blank()
                    Text(formatTimeAgo(item.last_time))
                      .fontColor('#ffababab')
                      .fontSize(14)
                  }
                  .alignItems(VerticalAlign.Top)
                  .width('100%')
                  .onClick(()=>{
                    this.toDetail(item)
                  })
                }
              .padding(20)
            })
        }
        .height('90%')
        .width('100%')
        .transition(TransitionEffect.OPACITY
          .combine(TransitionEffect.translate({x:50}))
        )
      }

    }
    .height('100%')
    .width('100%')
  }
}

