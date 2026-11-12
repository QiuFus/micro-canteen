
import { notificationType, requestData, WsSendMessage } from "../pages/main"
import { myserverurl } from "../LoginBranch/Page"
import { curves } from "@kit.ArkUI"
import { formatTimeAgo } from "../utils/DateComparison"
import { searchType, requestData as cd } from "../MainBranch/gotoDetailPage"
import { emitter } from "@kit.BasicServicesKit"
import { qfsGet, qfsPut } from "../utils/httpRequest"

const WSMESSAGE_EVENT_ID = 1;

@Component
export struct notificationPage{
  @State notificationList:notificationType[]=[]
  @Link showMe:number
  @State showItem:boolean=false
  @State gotoFood:searchType[]=[]
  @Consume('NavPathStack') pageState:NavPathStack

  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    switch (envelope.type){
      case 'notification_num':{
        this.getPage=1
        this.notificationList=[]
        this.getNotification()
        break;
      }
      default :{
        break;
      }
    }
  };
  private deleteDal: CustomDialogController = new CustomDialogController({
    builder: isdelete({deletef:()=>{}}),
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear(): void {
    this.getNotification()

    this.getUIContext()?.animateTo({
      curve:curves.springMotion(0.4,0.5)
    },()=>{
      this.showItem=true
    })
    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }

  @State getPage:number=1
  @State getPageIsLogin:boolean=false
  @State DataIsNull:boolean=false
  async getNotification(){
    const result=await qfsGet(`get/notification?page=${this.getPage}`) as requestData
    const getList=result.data as notificationType[]
    try {
      if (getList.length>0) {
        this.notificationList.push(...getList)
      }else{
        this.DataIsNull=true
      }
    }catch (err){
      console.error('[ztwjj]',err)
    }finally {
      this.getPageIsLogin=false
    }
  }

  build() {
    NavDestination(){
      Column(){
        Row({space:10}){
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(30).fontWeight(FontWeight.Bold)
            .onClick(()=>{
              this.getUIContext()?.animateTo({curve:curves.springMotion(0.4, 0.7)},()=>{
                this.showMe=-1
              })
            })
          Text('消息').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
            .fontSize(30).fontWeight(FontWeight.Bold)
            .bindMenu(this.MyMenu)
        }
        .width('100%').padding(20)

        if (this.showItem){
          List({space:14}){
            ForEach(this.notificationList,(i:notificationType)=>{
              ListItem(){
                Row({space:10}){
                  Column(){
                    Row().size({width:10,height:10}).borderRadius(10).backgroundColor(Color.Red)
                  }
                  .height(50).justifyContent(FlexAlign.Center)
                  .visibility(i.is_read==1?Visibility.Hidden:Visibility.Visible)
                  Image(i.payload.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${i.payload.avatar_url}`)
                    .size({width:50,height:50})
                    .borderRadius(10)
                  Column({space:5}){
                    if (i.type=='comment_liked') {
                      Text(`${i.payload.nickname}${i.merged_count>1?` 等 ${i.merged_count+' 人赞了你评论'}`:' 点赞了你评论'}`)
                        .constraintSize({maxWidth:'50%'})
                        .maxLines(2)
                        .textOverflow({overflow:TextOverflow.Ellipsis })
                    }else if (i.type=='food_liked') {
                      Text(`${i.payload.nickname}${i.merged_count>1?` 等 ${i.merged_count+' 人点赞了你菜品'}`:' 点赞了你菜品'}`)
                        .constraintSize({maxWidth:'50%'})
                        .maxLines(2)
                        .textOverflow({overflow:TextOverflow.Ellipsis })
                    }
                    else {
                      Text(`${i.payload.nickname}${i.type=='food_commented'?' 评论了你的菜品':' 回复了你'}`)
                        .constraintSize({maxWidth:'50%'})
                        .maxLines(2)
                        .textOverflow({overflow:TextOverflow.Ellipsis })
                      Text(i.payload.content)
                        .constraintSize({maxWidth:'50%'})
                        .maxLines(1)
                        .textOverflow({overflow:TextOverflow.Ellipsis})
                        .fontColor('#ff696969')
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                  Text(formatTimeAgo(i.created_at))
                    .fontColor('#ff808080')
                    .fontSize(14)
                }
                .alignItems(VerticalAlign.Top)
                .padding(10)
                .width('90%')
                .onClick(async ()=>{

                  const result=await qfsGet(`notification/get/${i.payload.food_id}`) as cd
                  this.gotoFood=result.data as searchType[]
                  let foodinfo=this.gotoFood[0]

                  foodinfo.notifizhi=i.payload.comment_id
                  // console.log('[ztwjj]:',JSON.stringify(foodinfo))
                  this.pageState.pushPathByName('gotoDetailPage',foodinfo,false)

                  qfsPut(`read/notification/${i.notification_id}`)
                })
              }
            })
          }
          .width('100%')
          .height('90%')
          .padding({left:20})
          .transition(TransitionEffect.OPACITY
            .combine(TransitionEffect.translate({x:100}))
          )
          .onReachEnd(()=>{
            if (!this.getPageIsLogin && !this.DataIsNull){
              this.getPageIsLogin=true
              this.getPage+=1
              this.getNotification()
            }
          })
        }

      }
      .size({width:'100%',height:'100%'})
      .backgroundColor(Color.White)
      .geometryTransition(`utielId1`,{follow:true})
    }
    .hideTitleBar(true)

  }


  @Builder
  MyMenu() {
    Menu() {
      MenuItem({ content: "设为已读" })
        .onClick(async () => {
          this.delOrRead('read')
        })
      MenuItem({ content: "一键清空" })
        .onClick(async () => {
          this.deleteDal= new CustomDialogController({
            builder: isdelete({deletef:()=>{
              this.delOrRead('del')
            }}),
            autoCancel: true
          });
          this.deleteDal.open()
        })
    }
  }

  async delOrRead(isType:string){
    await qfsPut(`put/notification/${isType}`)
  }


}

@Builder
export function notificationPageBuilder(){
  // notificationPage()
}

@CustomDialog
struct isdelete {
  onisdelete: CustomDialogController;
  deletef?:()=>void

  build() {
    Column({space:10}) {
      Text('确定要清空所有通知吗')
        .padding({top:16,left:12})
        .fontSize(24)
      Row(){
        Button('清空')
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