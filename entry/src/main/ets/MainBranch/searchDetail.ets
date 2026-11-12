import { curves } from "@kit.ArkUI"
import { myserverurl } from "../LoginBranch/Page";
import { qfsPost } from "../utils/httpRequest";

interface requestData{
  code:number
  msg: string
  data:searchType[]
}
interface searchType{
  type: string,
  name: string,
  id: number,
  detail: string,
  image_url:string,
  comment_count:number,
  like_count:number,
  is_liked:number
}
interface postType{keyword:string}

@Component
struct SearchDetail{
  pageState:NavPathStack=new NavPathStack()

  @State showbool: boolean=true
  @State searchText: string = ''
  @State keywork:string=''
  @State showCursor: boolean = true;
  @State allFoods: searchType[] =[]

  aboutToAppear(): void {
    this.getSearchDetail()
    setTimeout(()=>{
      this.searchText=''
      this.showCursor=false
    },100)
    setTimeout(()=>{
      this.animateRun()
    },110)

  }

  animateRun(){
    this.getUIContext()?.animateTo({
      curve:curves.springMotion(1,0.5)
    },()=>{
      this.showbool=!this.showbool
    })
  }

  async getSearchDetail(){
    const body:postType={keyword:this.keywork}

    const result=await qfsPost(`search/data`,body) as requestData
    this.allFoods=result.data
  }


  async toggleLike(foodData: searchType) {
    const originalLiked = foodData.is_liked;
    const originalCount = foodData.like_count;

    foodData.is_liked = foodData.is_liked==1?0:1
    foodData.like_count += foodData.is_liked ? 1 : -1;
    this.refreshCommentList(); // 触发 ArkUI 刷新

    try {

      const result=await qfsPost(`foods/${foodData.id}/like`) as requestData
      if (result.code !== 200) throw new Error('点赞失败');
    } catch (err) {
      foodData.is_liked = originalLiked;
      foodData.like_count = originalCount;
      this.refreshCommentList();
    }
  }

  private refreshCommentList() {
    this.allFoods = [...this.allFoods];
  }


  build() {
    NavDestination(){

      Column(){
          if (this.showbool) {
            Row() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .padding({left:10})
                .height(40)
                .visibility(this.showCursor?Visibility.Visible:Visibility.Hidden)
              TextInput({ text: $$this.searchText })
                .width('90%')
                .height(40)
                .backgroundColor(Color.Transparent)
            }
            .geometryTransition(`searchDetail`)
            .width('80%')
            .borderRadius(5)
            .borderWidth(2)
          }else {
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
                            Text(i.name).fontSize(20).textAlign(TextAlign.Start).fontWeight(FontWeight.Bold).width('100%')
                              .fontColor('#fff')
                            Row({space:8}){
                              Text(i.detail).fontSize(16).textAlign(TextAlign.Start).fontColor('#ffcdcdcd')
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
                    .width('80%')
                    .height(200)
                    .borderRadius(10)
                    .clip(true)
                    .geometryTransition(`id${i.id}`)
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
            .geometryTransition(`searchDetail`)
          }

      }
      .width('100%')

    }
    .title(this.showbool?'...':'搜索结果:')
    .onReady((ctx:NavDestinationContext)=>{
      this.pageState=ctx.pathStack
    })
    .height('100%')
    .width('100%')
  }
}

@Builder
export function SearchDetailBuilder(name:string,data:string){
  SearchDetail({searchText:data,keywork:data})
}


















