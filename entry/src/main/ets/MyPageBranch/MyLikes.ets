
import { myserverurl } from "../LoginBranch/Page"
import { curves } from "@kit.ArkUI"
import { searchType, requestData as cd, requestData } from "../MainBranch/gotoDetailPage"
import { qfsGet, qfsPost } from "../utils/httpRequest"

@Component
export struct MyLikes{
  @Link showMe:number
  @State showItem:boolean=false
  @State allFoods:searchType[]=[]
  @Consume('NavPathStack') pageState:NavPathStack

  aboutToAppear(): void {
    this.getNotification()

    this.getUIContext()?.animateTo({
      curve:curves.springMotion(0.4,0.5)
    },()=>{
      this.showItem=true
    })
  }

  @State getPage:number=1
  @State getPageIsLogin:boolean=false
  @State DataIsNull:boolean=false
  async getNotification(){
    const result=await qfsGet(`my-likes?page=${this.getPage}`) as cd
    const getList=result.data as searchType[]
    try {
      if (getList.length>0) {
        this.allFoods.push(...getList)
      }else{
        this.DataIsNull=true
      }
    }catch (err){
      console.error('[ztwjj]',err)
    }finally {
      this.getPageIsLogin=false
    }
  }


  async toggleLike(foodData: searchType) {
    const originalLiked = foodData.is_liked;
    const originalCount = foodData.like_count;

    foodData.is_liked = foodData.is_liked==1?0:1
    foodData.like_count += foodData.is_liked ? 1 : -1;
    this.allFoods = [...this.allFoods];
    try {

      const result=await qfsPost(`foods/${foodData.id}/like`) as requestData
      if (result.code !== 200) throw new Error('点赞失败');
    } catch (err) {
      foodData.is_liked = originalLiked;
      foodData.like_count = originalCount;
      this.allFoods = [...this.allFoods];
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
          Text('喜欢').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
        }
        .width('100%').padding(20)

        if (this.showItem){
          List({space:14}){
            ForEach(this.allFoods, (i: searchType) => {
              ListItem() {
                Column() {
                  Stack(){
                    Image(i.image_url==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${i.image_url}`)
                      .size({width:'100%',height:'100%'})
                    Column(){
                      Row(){
                          SymbolGlyph($r('sys.symbol.ellipsis_message_fill'))
                            .fontSize(20)
                            .fontColor(['#ffffffff'])
                            .margin({left:10})
                          Text(''+i.comment_count)
                            .fontSize(16)
                            .fontColor(Color.White)
                        Blank()
                        Row({space:10}){
                          SymbolGlyph($r('sys.symbol.hand_thumbsup_fill'))
                            .fontSize(18).margin({left:5})
                            .fontColor([i.is_liked==1? '#ffffdc1c' :'#ffffffff'])
                            .onClick(()=>{
                              this.toggleLike(i)
                            })
                          Text(''+i.like_count)
                            .fontSize(16)
                            .fontColor(Color.White)
                        }.width(60).padding(5).borderRadius(10).backgroundColor('#544f4f4f').backdropBlur(20)
                      }.width('100%').padding({right:10,top:10}).visibility(i.type=='food'?Visibility.Visible:Visibility.None)
                      Blank()
                      Column({space:5}){
                        Text(i.name).fontSize(20).textAlign(TextAlign.Start).fontWeight(FontWeight.Bold).width('100%')
                          .fontColor('#fff')
                        Text(i.detail).fontSize(16).textAlign(TextAlign.Start).fontColor('#ffe3e3e3')
                        .width('100%').padding({right:10})
                      }
                      .padding({top:26,left:10})
                      .size({width:'100%',height:80})
                      .backdropBlur(10) // 先设置背景模糊
                      .linearGradient({
                        direction: GradientDirection.Top,
                        colors: [
                          ['#ff545454', 0.1],
                          ['#00ffffff', 1.0]
                        ]
                      })
                    }
                    .size({width:'100%',height:'100%'})
                  }
                }
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .height(160)
                .backgroundColor('#ff87ab09')
                .borderRadius(10)
                .clip(true)
              }
              .width('90%')
              .onClick(()=>{
                this.pageState.pushPathByName('gotoDetailPage',i)
              })
            })
          }
          .lanes(2)
          .width('100%')
          .height('90%')
          .alignListItem(ListItemAlign.Center)
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
      .geometryTransition(`utielId2`,{follow:true})
    }
    .hideTitleBar(true)

  }
}

@Builder
export function MyLikesBuilder(){
  // notificationPage()
}