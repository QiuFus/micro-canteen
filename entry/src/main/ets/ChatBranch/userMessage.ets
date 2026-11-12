import {friendList} from '../TabBarPages/friendList'
import { curves } from '@kit.ArkUI'
import {myserverurl} from "../LoginBranch/Page"
import { wsManager } from '../utils/WebSocketManager'
import emitter from '@ohos.events.emitter';
import { qfsGet } from '../utils/httpRequest'

const WSMESSAGE_EVENT_ID = 1;

interface friendMsgList {
  message_id: number
  from_user_id: number
  to_user_id: number
  message_type: number
  content: string
  is_read: number
  send_time: string
  recall_time: string
  from_nickname: string
  from_avatar_url:string
  to_nickname: string
  to_avatar_url: string
}

interface friendMsgListData{
  code: number
  msg: string
  data:friendMsgList[]|friendMsgList
}

interface ChatPayload {
  to_user_id: number
  message_type: number
  content: string
}
interface WsSendMessage {
  type: string
  payload: ChatPayload
}
interface sendData{
  friend_id:number
}


@Component
struct UserMessage {
  pageState:NavPathStack=new NavPathStack()
  private listController: ListScroller = new ListScroller()

  @State showbool:boolean=true
  @State tishi:string=''
  @State text:string=''

  @State clickId:number=-1
  @State goAvatarUrl:string=''
  @State goNickname:string=''
  usedetail:friendList={
    user_id: 0,
    nickname: '',
    avatar_url: '',
    is_friend:1,
    unread_count:0,
    last_message:'',
    last_time:''
  }

  private chatCallback = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    // 只处理聊天消息
    if (envelope.type === 'chat') {
      const msg = envelope.payload as friendMsgList;
      this.friendMsgList.push(msg);
      setTimeout(() => {
        this.listController.scrollEdge(Edge.Bottom);
      }, 100);

      if (msg.from_user_id === this.usedetail.user_id) {
        wsManager.send(JSON.stringify({
          type: 'mark_read',
          payload: { friend_id: msg.from_user_id } as sendData
        }));
      }
    }
  };

  @State friendMsgList:friendMsgList[]=[]

  aboutToAppear(): void {
    this.getFriendMessageList()
    emitter.on({ eventId: WSMESSAGE_EVENT_ID },this.chatCallback);
    this.setisread()
    setTimeout(() => {
      this.listController.scrollEdge(Edge.Bottom)
    }, 100)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID, this.chatCallback);
  }


  setisread(){
    wsManager.send(JSON.stringify({
      type: 'mark_read',
      payload: { friend_id: this.usedetail.user_id } as sendData
    }));
  }

  sendMessage(){
    if (wsManager.getConnected()) {
      wsManager.send(JSON.stringify({
        type: 'chat',
        payload:{
          to_user_id: this.usedetail.user_id,
          message_type: 1,
          content: this.text
        } as ChatPayload
      }));
    }
    setTimeout(() => {
      this.listController.scrollEdge(Edge.Bottom)
    }, 100)
  }

  @State getPage:number=1
  @State getPageIsLogin:boolean=false
  @State DataIsNull:boolean=false
  async getFriendMessageList(){
    if(this.usedetail.user_id){
      try {
        const result=await qfsGet(`friend/message/${this.usedetail.user_id}?page=${this.getPage}&limit=20`) as friendMsgListData
        if (result.code==200) {
          const newMsg=result.data as friendMsgList[]
          if (newMsg.length>0) {
            this.friendMsgList.unshift(...newMsg)
          }else{
            this.DataIsNull=true
          }
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }finally {
        this.getPageIsLogin=false
        console.log('[ztwjj]聊天列表渲染数:',this.friendMsgList.length)
      }
    }
  }

  build() {
    NavDestination(){
      Stack(){
        Column(){
          List({scroller:this.listController}){
            ForEach(this.friendMsgList,(item:friendMsgList,index)=>{
              ListItem(){
                Row(){
                  Image(item.from_avatar_url==null? $r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${item.from_avatar_url}`)
                    .size({width:50,height:50})
                    .borderRadius(5)
                    .geometryTransition(`taimg${item.message_id}`,{follow:false})
                    .onClick(()=>{
                      this.getUIContext()?.animateTo({
                        curve:curves.springMotion(0.4,0.58)
                      },()=>{
                        this.showbool=!this.showbool
                        this.clickId=item.message_id
                        this.goAvatarUrl=item.from_avatar_url==null?'':item.from_avatar_url
                        this.goNickname=item.from_nickname
                      })
                    })
                  Text(item.content)
                    .backgroundColor(Color.White)
                    .fontSize(20)
                    .width(item.content.length>=9?'60%':'')
                    .transition(TransitionEffect.OPACITY)
                    .backgroundColor(Color.White)
                    .borderRadius(item.from_user_id==this.usedetail.user_id?{topRight:10,bottomRight:10,bottomLeft:10}:{topLeft:10,bottomRight:10,bottomLeft:10})
                    .padding(10)
                    .margin({left:10,right:10})
                  if (index==this.friendMsgList.length-1 && item.from_user_id!==this.usedetail.user_id && this.usedetail.is_friend==0) {
                    Column(){
                      Blank()
                      Row(){
                        Text('!')
                          .fontSize(14)
                          .fontColor(Color.White)
                      }
                      .justifyContent(FlexAlign.Center)
                      .borderRadius(18)
                      .size({height:18,width:18})
                      .backgroundColor(Color.Red)
                      .margin({left:5,right:5,bottom:8})
                    }
                    .height(50)
                  }

                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
                .reverse(item.from_user_id==this.usedetail.user_id?false:true)
              }
              .width('100%')
              .padding(20)
            })
          }
          .height('92%')
          .width('100%')
          .onReachStart(()=>{
            if (!this.getPageIsLogin && !this.DataIsNull){
              this.getPageIsLogin=true
              this.getPage+=1
              this.getFriendMessageList()
            }
          })

          Row(){
            TextInput({placeholder:'输入内容...',text:$$this.text})
              .borderRadius({topLeft:10,bottomLeft:10,topRight:0,bottomRight:0})
              .backgroundColor('#FFF8F1')
              .layoutWeight(1)
              .showError(this.tishi)
              .onChange(()=>{
                this.tishi=''
              })
            Button('发送',{type:ButtonType.Normal})
              .borderRadius({topLeft:0,bottomLeft:0,topRight:10,bottomRight:10})
              .backgroundColor('#ffb1dd25')
              .onClick(()=>{
                if (this.text.trim()!=='') {
                  this.sendMessage()
                  if(this.usedetail.is_friend==0){
                    AlertDialog.show({
                      message:'你们当前还不是好友',
                      confirm:{
                        value:'确定',
                        action:()=>{}
                      }
                    })
                  }
                  this.text=''
                }else {
                  this.tishi='不能发送空消息'
                }
              })
          }
          .margin({top:10})
          .width('94%')
          .alignItems(VerticalAlign.Top)
        }
        .width('100%')
        .height('100%')
        if (!this.showbool){
          LookUserSelf({showbool:this.showbool,clickId:this.clickId,avaurl:this.goAvatarUrl,nikname:this.goNickname})
        }
      }
    }
    .backgroundColor('#ffe7e7e7')
    .title(this.usedetail.nickname)
    .onReady((ctx: NavDestinationContext) => {
      this.pageState=ctx.pathStack;
    })
    .height('100%')
    .width('100%')
  }
}

@Builder
export function UserMessageBuilder(name:string,userlist:friendList){
  UserMessage({usedetail:userlist})
}
//userImg:$r('app.media.background'),
@Component
export struct LookUserSelf {
  @Link showbool:boolean
  @Prop clickId:number
  @Prop avaurl:string
  @Prop nikname:string

  build() {
    Column(){
      Image(this.avaurl==''?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${this.avaurl}`)
        .size({width:100,height:100})
        .borderRadius(100)
        .geometryTransition(`taimg${this.clickId}`,{follow:true})
        .onClick(()=>{
          this.getUIContext()?.animateTo({
            curve:curves.springMotion(0.4,0.58)
          },()=>{
            this.showbool=!this.showbool
          })
        })
      Text(this.nikname)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({top:20})
    }
    .backgroundColor('#ffe7e7e7')
    .height('100%')
    .width('100%')
  }
}