import {friendList,friendData} from '../TabBarPages/friendList'
import { curves } from '@kit.ArkUI'
import {myserverurl} from "../LoginBranch/Page"
import { requestData, requestitem, updata, WsSendMessage } from '../pages/main'
import { emitter } from '@kit.BasicServicesKit'
import { qfsDelete, qfsGet, qfsPost, qfsPut } from '../utils/httpRequest'

const WSMESSAGE_EVENT_ID = 1;

interface searchU{
  user_id:number
  nickname:string
  avatar_url:string
  is_friend: number
  has_pending_request: number
  has_received_request: number
  is_self:number
}
interface searchUData{
  code:number
  msg: string
  data:searchU
}
interface actiondata{
  requester_id:number
  action:string
}
interface datacode{
  code:number
  msg:string
}
interface putType{addressee_id:number}
interface deleteType{friend_id:number}

@Component
export struct AddOrDelete {
  @StorageLink('requestCount') requestCount: number = 0
  @State addOr:number=0
  @State showScroll:boolean=false
  @State friendList:friendList[]=[]
  @Link showMe:number


  private deleteDal: CustomDialogController = new CustomDialogController({
    builder: isdelete({deletef:()=>{}}),
    autoCancel: true,
    customStyle: true
  });


  async deleteFriend(id:number){
    const body={
      friend_id:id
    } as deleteType
    const result=await qfsDelete(`delete/friend`,body) as datacode
    if (result.code==200) {
      this.friendList.splice(this.friendList.findIndex(i=>i.user_id==id),1)
    }
  }


  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    if (envelope.type=='new_friend') {
      const newData=envelope.payload as updata
      this.friendList=newData.friendList
    }
  };

  aboutToAppear(): void {
    this.showpage()
    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }


  async showpage(){
    const result=await qfsGet(`friend/List`) as friendData
    this.friendList=result.data

    setTimeout(()=>{
      this.getUIContext()?.animateTo({
        curve:curves.springMotion(0.4,0.5)
      },()=>{
        this.showScroll=true
      })
    },50)
  }

  build() {
    Column(){
      if (this.addOr==0){
        Column(){
          Row({space:10}){
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(30).fontWeight(FontWeight.Bold)
              .onClick(()=>{
                this.getUIContext()?.animateTo({curve:curves.springMotion(0.4, 0.7)},()=>{
                  this.showMe=-1
                })
              })
            Text('管理搭子').fontSize(20).fontWeight(FontWeight.Bold)
            Blank()
          }.width('100%').padding(20)
          Row(){
              Row(){
                  Text('好友申请')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  if (this.requestCount>0) {
                    Row(){
                      Text('(')
                        .fontWeight(FontWeight.Bold)
                        .fontSize(16)
                      Text(this.requestCount>=99?'99+':''+this.requestCount+'')
                        .fontWeight(FontWeight.Bold)
                        .margin({left:2,right:2})
                        .fontColor(Color.Red)
                      Text(')')
                        .fontWeight(FontWeight.Bold)
                        .fontSize(16)
                    }
                  }
              }
              .backgroundColor(Color.White)
              .size({width:'45%',height:80})
              .geometryTransition('look_border',{follow:false})
              .onClick(()=>{
                this.getUIContext()?.animateTo({
                  curve:curves.springMotion(0.4,0.58)
                },()=>{
                  this.addOr=2
                })
              })
              .justifyContent(FlexAlign.Center)
              .borderWidth(2)
              .borderRadius(20)

            Row(){
              Text(`添加搭子`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .backgroundColor(Color.White)
            .size({width:'45%',height:80})
            .geometryTransition('border',{follow:false})
            .onClick(()=>{
              this.getUIContext()?.animateTo({
                curve:curves.springMotion(0.4,0.58)
              },()=>{
                this.addOr=1
              })
            })
            .justifyContent(FlexAlign.Center)
            .borderWidth(2)
            .borderRadius(20)

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          if (this.showScroll){
            Text(`我的搭子(${this.friendList.length})`)
              .margin(10)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .width('90%')
            List({space:20}){
              ForEach(this.friendList,(item:friendList,index)=>{
                ListItem(){
                  Row(){
                    Image(item.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${item.avatar_url}`)
                      .size({width:50,height:50})
                      .borderRadius(5)
                    Text(item.nickname)
                      .fontSize(20)
                      .margin({left:10})
                      .transition(TransitionEffect.OPACITY)
                    Blank()
                    Button('删除')
                      .backgroundColor('#ffcd2424')
                      .type(ButtonType.Normal)
                      .borderRadius(5)
                      .onClick(()=>{
                        this.deleteDal= new CustomDialogController({
                          builder: isdelete({deletef:()=>{
                            this.deleteFriend(item.user_id)
                          }}),
                          autoCancel: true
                        });
                        this.deleteDal.open()
                      })
                      .margin({right:5})
                  }
                  .width('100%')
                }
                .backgroundColor(Color.White)
                .borderRadius(10)
                .padding(14)
              })
            }
            .height('80%')
            .width('100%')
            .padding(20)
            .transition(TransitionEffect.OPACITY
              .combine(TransitionEffect.translate({x:50}))
            )
          }
        }
        .size({width:'100%',height:'90%'})
      }else if(this.addOr==1){
        addfriend({addOr:this.addOr})
      }else{
        lookfred({addOr:this.addOr})
      }
    }
    .backgroundColor('#ffe7e7e7')
    .height('100%')
    .width('100%')
    .geometryTransition(`utielId0`,{follow:true})
  }
}

@Component
export struct addfriend {
  @Link addOr:number
  @State tishi:string=''
  @State text:string=''
  @State searchlist:searchU={
    user_id:-1,
    nickname:'',
    avatar_url:'',
    is_friend: -1,
    has_pending_request: -1,
    has_received_request: -1,
    is_self:-1
  }

  private loginDialog: CustomDialogController = new CustomDialogController({
    builder: TextDialog({ message: '' }),
    autoCancel: true
  });

  async searchFriend(){
    try {
      console.log('ztwjj'+this.text)
      const result=await qfsGet(`search/friend/${encodeURIComponent(this.text)}`) as searchUData
      if (result.code==200) {
        this.searchlist=result.data
      }else {
        this.loginDialog= new CustomDialogController({
          builder: TextDialog({ message: result.msg }),
          autoCancel: true
        });
        this.loginDialog.open()
      }

    }catch (err){
      console.error('[ztwjj]搜索失败：',err.message)
    }
  }

  async addFriend(id:number){

    const body={ addressee_id:id } as putType
    const result=await qfsPost(`add/friend`,body) as datacode

    if (result.code==200) {
      this.searchlist.has_pending_request=1
    }else if (result.code==400) {
      this.loginDialog= new CustomDialogController({
        builder: TextDialog({ message: result.msg }),
        autoCancel: true
      });
      this.loginDialog.open()
    }
  }

  async actionFriend(val:string,id:number){

    const sendData:actiondata={
      requester_id:id,
      action:val
    }
    if (val=='reject') {
      this.searchlist.nickname=''
    }else if (val=='accept') {
      this.searchlist.has_received_request=0
      this.searchlist.is_friend=1
    }

    await qfsPut(`put/friend`,sendData)
  }

  build() {
    Column(){
      Text('添加搭子')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({top:20,bottom:40})
      Row(){
        TextInput({placeholder:'搜索搭子...',text:$$this.text})
          .borderRadius({topLeft:10,bottomLeft:10,topRight:0,bottomRight:0})
          .backgroundColor('#FFF8F1')
          .layoutWeight(1)
          .showError(this.tishi)
          .onChange(()=>{
            this.tishi=''
          })
        Button('搜索',{type:ButtonType.Normal})
          .borderRadius({topLeft:0,bottomLeft:0,topRight:10,bottomRight:10})
          .backgroundColor('#ffb1dd25')
          .onClick(()=>{
            if (this.text.trim()!=='') {
              this.searchFriend()
            }else {
              return
            }
          })
      }
      .margin({top:10,bottom:20})
      .width('94%')
      .alignItems(VerticalAlign.Top)

      if (this.searchlist.nickname){
        Row(){
          Image(this.searchlist.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${this.searchlist.avatar_url}`)
            .size({width:50,height:50})
            .borderRadius(5)
          Text(this.searchlist.nickname)
            .fontSize(20)
            .margin({left:10})
            .transition(TransitionEffect.OPACITY)
          Blank()

          if (this.searchlist.has_received_request==1) {
            Button('接受')
              .backgroundColor('#ff33c400')
              .type(ButtonType.Normal)
              .borderRadius(5)
              .margin({right:5})
              .onClick(()=>{
                this.actionFriend('accept',this.searchlist.user_id)
              })
          }
          Button(this.searchlist.is_self==1?'我自己':this.searchlist.is_friend==1?'已是好友':this.searchlist.has_pending_request==1?'等待验证':this.searchlist.has_received_request==1?'拒绝':'添加')
            .backgroundColor(this.searchlist.is_self==1?'#ffababab':this.searchlist.is_friend==1? '#ffababab' :this.searchlist.has_pending_request==1?
              '#ffababab':'#ffcd2424')
            .onClick(()=>{
              if (this.searchlist.has_received_request==1) {
                this.actionFriend('reject',this.searchlist.user_id)
              }else if(this.searchlist.is_friend==0 && this.searchlist.has_pending_request==0 && this.searchlist.has_received_request==0 &&
              this.searchlist.is_self==0){
                this.addFriend(this.searchlist.user_id)
              }
            })
            .type(ButtonType.Normal)
            .borderRadius(5)
        }
        .padding({left:20,right:20})
        .width('100%')
      }

    }
    .backgroundColor(Color.White)
    .geometryTransition('border',{follow:true})
    .onClick(()=>{
      this.getUIContext()?.animateTo({
        curve:curves.springMotion(0.4,0.58)
      },()=>{
        this.addOr=0
      })
    })
    .borderWidth(4)
    .borderRadius(10)
    .height('80%')
    .width('90%')
  }
}

@Component
export struct lookfred {
  @Link addOr:number

  @State requestList:requestitem[]=[]

  aboutToAppear(): void {
    this.getrequestlist()
  }

  async getrequestlist(){
    const result=await qfsGet(`add/me`) as requestData
    this.requestList=result.data as requestitem[]
  }

  async actionFriend(val:string,id:number){
    const sendData:actiondata={
      requester_id:id,
      action:val
    }

    await qfsPut(`put/friend`,sendData)
  }

  build() {
    Column(){
      Text('好友申请')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({top:20})
      List(){
        ForEach(this.requestList,(item:requestitem,index)=>{
            ListItem(){
              Row(){
                Image(item.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${item.avatar_url}`)
                  .size({width:50,height:50})
                  .borderRadius(5)
                Text(item.nickname)
                  .fontSize(20)
                  .margin({left:10})
                  .transition(TransitionEffect.OPACITY)
                Blank()
                Button(item.friendship_id==-1?'已接受':'接受')
                  .backgroundColor(item.friendship_id==-1?'#ffababab':'#ff33c400')
                  .type(ButtonType.Normal)
                  .borderRadius(5)
                  .margin({right:5})
                  .onClick(()=>{
                    this.actionFriend('accept',item.user_id)
                    this.requestList[index]={
                      user_id:item.user_id,
                      nickname:item.nickname,
                      avatar_url:item.avatar_url,
                      friendship_id:-1
                    }
                  })
                if (item.friendship_id!==-1) {
                  Button('拒绝')
                    .backgroundColor('#ffcd2424')
                    .type(ButtonType.Normal)
                    .borderRadius(5)
                    .onClick(()=>{
                      this.actionFriend('reject',item.user_id)
                      this.requestList = this.requestList.filter(i=> i.user_id !== item.user_id)
                    })
                }
              }
              .width('100%')
            }
            .padding(14)
        })
      }
      .width('100%')
      .layoutWeight(1)

    }
    .backgroundColor(Color.White)
    .geometryTransition('look_border',{follow:true})
    .onClick(()=>{
      this.getUIContext()?.animateTo({
        curve:curves.springMotion(0.4,0.58)
      },()=>{
        this.addOr=0
      })
    })
    .borderWidth(4)
    .borderRadius(10)
    .height('80%')
    .width('90%')
  }
}

@CustomDialog
struct TextDialog {
  controller: CustomDialogController;
  message: string = '';

  build() {
    Column({space:20}) {
      Text(this.message)
        .padding({top:10,left:12})
        .fontSize(24)
      Button('确定')
        .backgroundColor('rgba(255,255,255,0)')
        .fontColor('#ff8cbf30')
        .onClick(() => {
          this.controller.close();
        })
    }
  }
}

@CustomDialog
struct isdelete {
  onisdelete: CustomDialogController;
  deletef?:()=>void

  build() {
    Column({space:10}) {
      Text('确定要删除该好友吗')
        .padding({top:16,left:12})
        .fontSize(24)
      Row(){
        Button('删除')
          .backgroundColor('rgba(255,255,255,0)')
          .fontColor('#ffcd2424')
          .onClick(() => {
            if (this.deletef) {
              this.deletef()
            }
            this.onisdelete.close();
          })
        Button('取消')
          .backgroundColor('rgba(255,255,255,0)')
          .fontColor(Color.Black)
          .onClick(()=>{
            this.onisdelete.close();
          })
      }
    }
  }
}