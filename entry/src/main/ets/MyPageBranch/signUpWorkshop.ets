import { curves, SymbolGlyphModifier } from "@kit.ArkUI"
import { qfsGet, qfsPost, qfsPut } from "../utils/httpRequest"
import { setFoodDetailType, requestData, getTtype, WsSendMessage } from "../pages/main"
import { formatTimeAgo } from "../utils/DateComparison"
import { emitter } from "@kit.BasicServicesKit"

const WSMESSAGE_EVENT_ID = 1;

interface postType{ province:string, city:string, district:string, schoolName:string, canteenName:string, workshopName:string}

@Component
struct singUpWorkshop{

  @State workshopList:getTtype[]=[]
  @State isShowSheet:boolean=false

  @State foodId:number=-1
  private pageStack:NavPathStack=new NavPathStack()
  private deleteDal: CustomDialogController = new CustomDialogController({
    builder: isdelete({deletef:()=>{},message:'',val:'',colzhi:''}),
    autoCancel: true,
    customStyle: true
  });
  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    switch (envelope.type){
      case 'up_workshop':{
        this.getSingUpWorkshop()
        break;
      }
      default :{
        break;
      }
    }
  };

  aboutToAppear(): void {

    this.getSingUpWorkshop()

    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }

  async getSingUpWorkshop(){
    const result=await qfsGet(`get/signUp/workshop`) as requestData
    this.workshopList=result.data as getTtype[]
  }

  @State text_province:string=''
  @State text_city:string=''
  @State text_district:string=''
  @State school_name:string=''
  @State c_name:string=''
  @State w_name:string=''

  async singUpWorkshopData(){
    const singUpData={
      province:this.text_province,
      city:this.text_city,
      district:this.text_district,
      schoolName:this.school_name,
      canteenName:this.c_name,
      workshopName:this.w_name
    } as postType

    try {
      const result=await qfsPost(`signUp/workshop`,singUpData) as requestData

      this.deleteDal= new CustomDialogController({
        builder: isdelete({message:result.msg,val:'确定',colzhi:'#ff8cbf30'}),
        autoCancel: true
      });
      this.deleteDal.open()

    }catch (err){
      console.warn('[ztwjj]注册失败：',err)
    }
  }


  build() {
    NavDestination(){
      List({space:20}){
        ForEach(this.workshopList,(i:getTtype)=>{
          ListItem(){
              Column({space:20}){
                Row(){
                  Text(i.w_name)
                    .fontSize(24).fontWeight(FontWeight.Bold)
                  Blank()
                  Text(formatTimeAgo(i.created_at))
                    .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#ffc6c6c6')
                }.width('100%').alignItems(VerticalAlign.Top)
                Scroll(){
                  Row({space:10}){
                    Text(i.school_name)
                      .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#ff818181')
                    Text(i.c_name)
                      .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#ff818181')
                  }
                }.constraintSize({maxWidth:'80%'}).scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
              }.alignItems(HorizontalAlign.Start).width('100%')
          }
          .shadow({
            radius:8,
            offsetY:14,
            color:'#ff9d9d9d'
          })
          .borderRadius(5).padding(20).width('100%').backgroundColor(Color.White)
        })
      }
      .padding(20)
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({x:100}))
      )
      .bindSheet($$this.isShowSheet, this.buildSheet(), {
        height: 700,          // 弹出层高度
        showClose: true,       // 是否显示关闭图标
        dragBar: true,         // 是否显示顶部拖动条
        onDisappear: () => {
          console.log('底部弹窗已关闭')
        }
      })
    }
    .onReady((ctx:NavDestinationContext)=>{
      this.pageStack=ctx.pathStack
    })
    .title('管理作坊')
    .backgroundColor('#ffececec')
    .menus([
      {
        value: 'add',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
          .fontWeight(FontWeight.Bold),
        action: () => {
          this.isShowSheet=true
        }
      }
    ])
  }

  @Builder
  buildSheet() {
    Column({space:30}) {
      Text('注册作坊')
        .fontSize(24).fontWeight(FontWeight.Bold)

      Column({space:20}){

        Row({space:4}){
          Text('省份：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({placeholder:'请输入省份',text:$$this.text_province})
            .backgroundColor(Color.White).borderRadius(0)
            .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(120)
        }

        Row({space:4}) {
          Text('城市：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({ placeholder: '请输入城市', text: $$this.text_city })
            .backgroundColor(Color.White)
            .borderRadius(0)
            .borderWidth({ bottom: 1 })
            .borderColor('#ffa0a0a0')
            .width(120)
        }

        Row({space:4}){
          Text('区县：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({placeholder:'请输入区县',text:$$this.text_district})
            .backgroundColor(Color.White).borderRadius(0)
            .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(120)
        }

        Row({space:8}){
          Text('学校：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({placeholder:'请输入学校',text:$$this.school_name})
            .backgroundColor(Color.White).borderRadius(0)
            .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
        }

        Row({space:8}){
          Text('食堂：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({placeholder:'请输入学校',text:$$this.c_name})
            .backgroundColor(Color.White).borderRadius(0)
            .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
        }

        Row({space:8}){
          Text('作坊：').fontSize(20).fontWeight(FontWeight.Bold)
          TextInput({placeholder:'请输入学校',text:$$this.w_name})
            .backgroundColor(Color.White).borderRadius(0)
            .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .size({width:'100%'})

      Button('注册',{type:ButtonType.Normal}).width('60%').borderRadius(5).backgroundColor('#ff8cbf30')
        .onClick(async ()=>{
          if (  !this.text_province|| !this.text_city||!this.text_district|| !this.school_name|| !this.c_name|| !this.w_name) {
            this.deleteDal= new CustomDialogController({
              builder: isdelete({message:'任意信息不能为空',val:'确定',colzhi:'#ff8cbf30'}),
              autoCancel: true
            });
            this.deleteDal.open()
          }else {
            this.singUpWorkshopData()
            this.isShowSheet=false
          }
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 10, topRight: 10 })
  }

}

@Builder
export function singUpWorkshopBuilder(){
  singUpWorkshop()
}


@CustomDialog
struct isdelete {
  onisdelete: CustomDialogController;
  message:string=''
  val:string=''
  colzhi:string=''
  deletef?:()=>void

  build() {
    Column({space:10}) {
      Text(this.message)
        .padding({top:16,left:12})
        .fontSize(24)
      Row(){
        Button(this.val)
          .backgroundColor('rgba(255,255,255,0)')
          .fontColor(this.colzhi)
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