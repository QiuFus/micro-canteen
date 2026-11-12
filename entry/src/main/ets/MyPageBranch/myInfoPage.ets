import { curves, router } from "@kit.ArkUI"
import { wsManager } from "../utils/WebSocketManager"


@Component
export struct myInfoPage{

  @Link showMe:number
  @Prop nickname:string
  @State showItem:boolean=false
  @Consume('NavPathStack') pageState:NavPathStack

  private username=AppStorage.get('User_username') as string
  private role=AppStorage.get('role') as string

  setNickname(){
    AlertDialog.show({
      message:'您的修改次数已用完',
      confirm:{
        value:'确定',
        fontColor:'#ff87ab09',
        action:()=>{}
      }
    })
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
          Text('个人信息').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
        }
        .width('100%').padding(20)

        Column({space:10}){
          Row({space:10}){
            Text('账号:')
              .fontWeight(FontWeight.Bold).fontSize(22)
            Text(this.username).borderWidth({bottom:1}).fontColor('#ff808080')

          }.width('100%')


          Row({space:10}){
            Text('昵称:')
              .fontWeight(FontWeight.Bold).fontSize(22)
            Text(this.nickname).borderWidth({bottom:1}).fontColor('#ff808080')
            Blank()
            Button('修改').type(ButtonType.Normal).borderRadius(10).backgroundColor('#ffbfbfbf')
              .fontColor(Color.White)
              .onClick(()=>this.setNickname())
          }.width('100%')


          Row({space:10}){
            Text('我的身份:')
              .fontWeight(FontWeight.Bold).fontSize(22)
            Text(this.role=='admin'?'超级管理员':(this.role=='student'?'学生':'食堂工作人员')).borderWidth({bottom:1}).fontColor('#ff808080')
          }.width('100%')

          Blank()

          Button('退出登录').type(ButtonType.Normal).borderRadius(10).width('80%').padding(10).backgroundColor('#ffbfbfbf')
            .fontColor(Color.White)
            .onClick(()=>{

              AlertDialog.show({
                message:'确定要退出账号吗？',
                primaryButton:{
                  value:"确定",
                  action:()=>{
                    wsManager.close()
                    AppStorage.delete('authToken')

                    router.replaceUrl({ url:'LoginBranch/Page' })
                  },
                  fontColor:'#ff87ab09',
                },
                secondaryButton:{
                  value:'取消',
                  fontColor:'#333',
                  action:()=>{}
                }
              })
            })
        }
        .padding(20).width('100%').layoutWeight(1)


      }
      .size({width:'100%',height:'100%'})
      .geometryTransition(`utielId4`,{follow:true})
    }
    .hideTitleBar(true)
  }
}