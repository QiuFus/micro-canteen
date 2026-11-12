import { curves } from "@kit.ArkUI"
import { qfsGet } from "../utils/httpRequest"
import { putfoodType, requestData, WsSendMessage } from "../pages/main"
import { formatTimeAgo } from "../utils/DateComparison"
import { myserverurl } from "../LoginBranch/Page"
import { emitter } from "@kit.BasicServicesKit"

const WSMESSAGE_EVENT_ID = 1;

@Component
export struct setFoods{
  @Link showMe:number
  @State showItem:boolean=false
  @Consume('NavPathStack') pageState:NavPathStack
  private role=AppStorage.get('role') as string

  @State foodList:putfoodType[]=[]

  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    switch (envelope.type){
      case 'up_sentFood':{
        this.getMySentFood()
        break;
      }
      default :{
        break;
      }
    }
  };


  aboutToAppear(): void {

    this.getMySentFood()

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

  async getMySentFood(){
    try {
      const result=await qfsGet(`get/sent_food`) as requestData
      this.foodList=result.data as putfoodType[]
    }catch(err){
      console.error('[ztwjj]',err)
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
          Text('发布详情').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          if (this.role=='admin'){
            SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
              .fontSize(30).fontWeight(FontWeight.Bold)
              .bindMenu(this.MyMenu)
          }else {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(30).fontWeight(FontWeight.Bold)
              .onClick(()=> {
                this.getUIContext()?.animateTo({
                  curve:curves.springMotion(0.7,0.6)
                },()=>{
                  this.pageState.pushPathByName('setFoodDetail',undefined)
                })
              })
          }

        }
        .width('100%').padding(20)

        List({space:14}){
          ForEach(this.foodList,(i:putfoodType)=>{
            ListItem(){
              Row({space:10}){
                Image(i.image_url==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${i.image_url}`)
                  .size({width:100,height:100})
                Column({space:10}){
                  Row({space:10}){
                    Text(i.name)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                    SymbolGlyph($r('sys.symbol.square_and_pencil'))
                      .fontSize(20).fontWeight(FontWeight.Bold) .fontColor(['#ffb3b3b3'])
                  }
                  Text('发布时间：'+formatTimeAgo(i.created_at))
                    .fontColor('#ff808080')
                    .fontSize(16)
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceAround)
                .height(100)
              }
              .alignItems(VerticalAlign.Top)
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .width('90%')
              .shadow({
                radius:8,
                offsetY:14,
                color:'#ffc8c8c8'
              })
              .onClick(()=>{
                this.getUIContext()?.animateTo({
                  curve:curves.springMotion(0.7,0.6)
                },()=>{
                  this.pageState.pushPathByName('setFoodDetail',i.food_id)
                })
              })
            }
          })
        }
        .width('100%')
        .height('90%')
        .padding({bottom:10})
        .alignListItem(ListItemAlign.Center)
        .transition(TransitionEffect.OPACITY
          .combine(TransitionEffect.translate({x:100}))
        )
      }
      .size({width:'100%',height:'100%'})
      .backgroundColor('#ffececec')
      .geometryTransition(`utielId3`,{follow:true})
    }
    .hideTitleBar(true)

  }

  @Builder
  MyMenu() {
    Menu() {
      MenuItem({ content: "管理作坊" })
        .onClick(() => {
          this.getUIContext()?.animateTo({
            curve:curves.springMotion(0.7,0.6)
          },()=>{
            this.pageState.pushPathByName('singUpWorkshop',undefined)
          })
        })
      MenuItem({ content: "添加菜品" })
        .onClick(() => {
          this.getUIContext()?.animateTo({
            curve:curves.springMotion(0.7,0.6)
          },()=>{
            this.pageState.pushPathByName('setFoodDetail',undefined)
          })
        })
    }
  }


}

@Builder
export function setFoodsBuilder(){
  // setFoods()
}

