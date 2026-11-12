import { curves } from "@kit.ArkUI"
import { myserverurl } from "../LoginBranch/Page";
import { qfsGet, qfsPost } from "../utils/httpRequest";
import { CommentChildrenDetail, CommentDetail } from "./CommentDetail";

export interface requestData{
  code:number
  msg: string
  data:searchType[] |commentType[]|commentType|searchType|locateType|toggleType
  postedBy:number
}

export class searchType{
  type: string=''
  name: string=''
  id: number=-1
  detail: string=''
  image_url:string=''
  comment_count:number=0
  like_count:number=0
  notifizhi:number=-1
  is_liked:number=0
}

export class commentType {
  comment_id:number= 0
  food_id:number=0
  user_id:number= 0
  parent_id:number=0
  reply_to_user_id:number=0
  content:string= ""
  like_count:number= 0
  reply_count:number= 0
  reply_nickname:string=""
  created_at: string=""
  nickname:string= ""
  avatar_url:string= ""
  is_liked:number=0
}
export class locateType{
  food_id:number= -1
  comment_type:string=""
  target_comment_id:number= 0
  parent_comment_id: number=0
  page:number= 0
  pageSize:number= 0
}

export class toggleType{
  liked:boolean=false
  action:string=''
}
interface postType{
  typeName:string,
  id:number
}

@Component
struct gotoDetailPage{
  pageState:NavPathStack=new NavPathStack()

  @State showbool: boolean=false
  @State titleData:searchType=new searchType()

  @State showCursor: boolean = true;
  @State CommentShow:boolean=false
  @State allFoods: searchType[] =[]

  @State locateData:locateType=new locateType()


 async aboutToAppear(){

    this.getSearchDetail(this.titleData.type,this.titleData.id)
    this.isLiked=this.titleData.is_liked
    this.likeCcount=this.titleData.like_count

   console.log('[ztwjj]notifizhi:',this.titleData.notifizhi)
    if (this.titleData.notifizhi!==undefined && this.titleData.notifizhi!==0) {

      const result=await qfsGet(`comment/locate/${this.titleData.notifizhi}`) as requestData
      this.locateData=result.data as locateType
    }
    setTimeout(()=>{
      this.animateRun()
    },16)

  }

  animateRun(){
    this.getUIContext()?.animateTo({
      curve:curves.springMotion(0.5,0.8)
    },()=>{
      this.showbool=!this.showbool
      if (this.titleData.type=='food') {
        this.CommentShow=true
      }
    })
  }

  async getSearchDetail(typeName:string,id:number){
    const body:postType={
      typeName:typeName,
      id:id
    }
    try {
      const result=await qfsPost(`search/detail`,body) as requestData
      if (result.code==200) {
        this.allFoods=result.data as searchType[]
      }
    }catch (err){
      console.error('获取失败：',err.message)
    }
  }


  @State likeCcount:number=-1
  @State isLiked:number=-1
  async toggleLike(foodData: searchType) {
    const originalLiked = foodData.is_liked;
    const originalCount = foodData.like_count;

    foodData.is_liked = foodData.is_liked==1?0:1
    foodData.like_count += foodData.is_liked ? 1 : -1;
    if (!this.CommentShow) {
      this.allFoods = [...this.allFoods];
    } else {
      this.likeCcount=foodData.like_count
      this.isLiked=foodData.is_liked
    }
    try {
      const result=await qfsPost(`foods/${foodData.id}/like`) as requestData
      if (result.code !== 200) throw new Error('点赞失败');
    } catch (err) {
      foodData.is_liked = originalLiked;
      foodData.like_count = originalCount;
      if (!this.CommentShow) {
        this.allFoods = [...this.allFoods];
      } else {
        this.likeCcount=foodData.like_count
        this.isLiked=foodData.is_liked
      }
    }
  }


  build() {
    NavDestination(){
      if (this.showbool){
        Stack(){
          Column(){
            Column() {
              Stack(){
                Image(this.titleData.image_url==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${this.titleData.image_url}`)
                  .size({width:'100%',height:'100%'})
                Column(){
                  Blank()
                  Column({space:5}){
                    Text(this.titleData.name).fontSize(24).textAlign(TextAlign.Start).fontWeight(FontWeight.Bold).width('100%')
                      .fontColor('#fff')
                    Row({space:8}){
                      Text(this.titleData.detail).fontSize(16).textAlign(TextAlign.Start).fontColor('#ffcdcdcd')
                      Blank()
                      if (this.CommentShow){
                        SymbolGlyph($r('sys.symbol.hand_thumbsup_fill'))
                          .fontSize(20)
                          .fontColor([this.isLiked==1? '#ffffdc1c' :'#ffffffff'])
                          .onClick(()=>{
                            this.toggleLike(this.titleData)
                          })
                        Text(''+this.likeCcount)
                          .fontSize(16)
                          .fontColor(Color.White)
                        SymbolGlyph($r('sys.symbol.ellipsis_message_fill'))
                          .fontSize(20)
                          .fontColor(['#ffffffff'])
                        Text(''+this.titleData.comment_count)
                          .fontSize(16)
                          .fontColor(Color.White)
                      }
                    }
                    .width('100%').padding({right:10})
                  }
                  .padding({top:20,left:10})
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
            .width('100%')
            .height(200)
            .clip(true)
            .geometryTransition(`id${this.titleData.id}`)

            if (!this.CommentShow) {
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
                                Text(i.detail).fontSize(16).textAlign(TextAlign.Start).fontColor('#ffdddddd')
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
                      .justifyContent(FlexAlign.Center)
                      .width('80%')
                      .height(200)
                      .backgroundColor('#ff528ad7')
                      .borderRadius(10)
                      .clip(true)
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
              .size({width:'100%',height:'70%'})
              .transition(TransitionEffect.OPACITY.animation({ curve: curves.springMotion(0.8, 0.5)})
                .combine(TransitionEffect.translate({y:100}))
              )
            }else {
              CommentDetail({foodId:this.titleData.id,foodType:this.titleData.type,parentData:this.parentData,
                showChildren:this.showChildren,locateData:this.locateData})
            }
          }
          if(this.showChildren){
            CommentChildrenDetail({getparent:this.parentData,showChildren:this.showChildren,
              foodId:this.titleData.id,locateData:this.locateData})
          }
        }
        .size({height:'100%',width:'100%'})
      }
    }
    .title(this.showbool?this.titleData.name:'')
    .onReady((ctx:NavDestinationContext)=>{
      this.pageState=ctx.pathStack
    })
    .height('100%')
    .width('100%')
  }
  @State parentData:commentType=new commentType()
  @State showChildren:boolean=false
}

@Builder
export function gotoDetailPageBuilder(name:string,data:searchType){
  gotoDetailPage({titleData:data})
}

