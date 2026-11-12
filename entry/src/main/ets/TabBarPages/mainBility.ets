import { curves, SymbolGlyphModifier } from "@kit.ArkUI"
import { requestData, searchType } from "../MainBranch/gotoDetailPage"
import { qfsGet, qfsPost } from "../utils/httpRequest"
import { myserverurl } from "../LoginBranch/Page"

@Component
export struct MainBility{
  @Consume('NavPathStack') pageState:NavPathStack

  @State allFoods:searchType[]=[]

  aboutToAppear(): void {
    this.getFoodsList()
  }

  async  getFoodsList(){
    const foodData=await qfsGet('random/foods') as requestData
    this.allFoods=foodData.data as searchType[]
    console.log('[ztwjj]allFoods:',JSON.stringify(this.allFoods))
  }



  async toggleLike(foodData: searchType) {
    const originalLiked = foodData.is_liked;
    const originalCount = foodData.like_count;

    foodData.is_liked = foodData.is_liked==1?0:1
    foodData.like_count += foodData.is_liked ? 1 : -1;
    this.allFoods = [...this.allFoods];
    try {
      const res = await qfsPost(`foods/${foodData.id}/like`) as requestData
      if (res.code !== 200) throw new Error('点赞失败');
    } catch (err) {
      foodData.is_liked = originalLiked;
      foodData.like_count = originalCount;
      this.allFoods = [...this.allFoods];
    }
  }

  build() {
    Navigation() {
      Column(){
        List({ space: 20 }) {
          ForEach(this.allFoods, (i: searchType) => {
            ListItem() {
              Column() {
                Stack(){
                  Image(i.image_url==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${i.image_url}`)
                    .size({width:'100%',height:'100%'})
                  Column(){
                    Row(){
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
                      Text(i.name).fontSize(20).textAlign(TextAlign.Start).fontWeight(FontWeight.Bold).width('100%').fontColor('#ffffffff')
                      Row({space:8}){
                        Text(i.detail).fontSize(16).textAlign(TextAlign.Start).fontColor('#ffe0e0e0')
                        Blank()
                        if (i.type=='food') {
                          SymbolGlyph($r('sys.symbol.ellipsis_message_fill'))
                            .fontSize(20)
                            .fontColor(['#ffffffff'])
                          Text(''+i.comment_count)
                            .fontSize(16)
                            .fontColor(Color.White)
                        }
                      }
                      .width('100%').padding({right:10})
                    }
                    .padding({top:26,left:10})
                    .size({width:'100%',height:80})
                    // .backdropBlur(10) // 先设置背景模糊
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
              .width('80%')
              .height(200)
              .backgroundColor('#ff87ab09')
              .borderRadius(10)
              .clip(true)
              .shadow({
                radius:8,
                offsetY:10,
                color: '#ffa2a2a2'
              })
            }
            .onClick(()=>{
              this.pageState.pushPathByName('gotoDetailPage',i,false)
            })
          })
        }
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .height('100%')
        .padding({ top: 20, bottom: 20 })
        .scrollBar(BarState.Off)
      }
      .size({width:'100%',height:'100%'})
      .transition(TransitionEffect.OPACITY.animation({ curve: curves.springMotion(0.8, 0.5)})
        .combine(TransitionEffect.translate({y:100}))
      )
    }
    .title('吃点儿啥呢')
    .subTitle('玩转食堂，从这里开始！')
    .titleMode(NavigationTitleMode.Free)
    .menus([
      {
        value: 'search',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
          .fontWeight(FontWeight.Bold),
        action: () => this.pageState.pushPathByName('search',undefined,false)
      },
      {
        value: 'refresh',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise'))
          .fontWeight(FontWeight.Bold),
        action: () =>this.getFoodsList()
      }
    ])
  }
}

//https://developer.huawei.com/consumer/cn/design/harmonyos-symbol/
