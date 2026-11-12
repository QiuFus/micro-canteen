
import { myserverurl } from "../LoginBranch/Page"
import { formatTimeAgo } from "../utils/DateComparison"
import { commentType, locateType, requestData, searchType, toggleType } from "./gotoDetailPage"
import { curves, PromptAction } from "@kit.ArkUI"
import { wsManager } from "../utils/WebSocketManager"
import { emitter } from "@kit.BasicServicesKit"
import { WsSendMessage } from "../pages/main"
import { qfsGet, qfsPost } from "../utils/httpRequest"

interface snf{parent_id:number}
interface postType{
  food_id:number,
  parent_id: number|null,
  reply_to_user_id:number|null,
  content:string
}
const WSMESSAGE_EVENT_ID = 1;

@Component
export struct CommentDetail{
  @Prop foodId:number
  @Prop foodType:string
  private uiContext: UIContext = this.getUIContext();

  @State commentList:Array<commentType>=[]
  @State tishi:string=''
  @State text:string=''
  @State placeholderVal:string='发表评论'

  @Link showChildren:boolean
  @Link parentData:commentType

  @Prop locateData:locateType
  @State locateIndex:number=-1
  private scroller:Scroller=new Scroller()
  @State goBug:boolean=true

  private globalMessageHandler = (eventData: emitter.EventData) => {
    const envelope = JSON.parse(eventData.data?.wsMessage) as WsSendMessage;
    switch (envelope.type){
      case 'updata_com':{
        this.locateUtile(this.foodId)
        break;
      }
      default :{
        break;
      }
    }
  };

  aboutToAppear(): void {
    emitter.on({eventId:WSMESSAGE_EVENT_ID},this.globalMessageHandler)
    this.locateUtile(this.foodId)

  }

  aboutToDisappear(): void {
    emitter.off(WSMESSAGE_EVENT_ID,this.globalMessageHandler)
  }

  async locateUtile(fid:number){
    if (this.locateData.comment_type=="top-level" && this.goBug) {
      this.getPage=this.locateData.page
      try {
        const result=await qfsGet(`render/comment/${fid}?page=${this.getPage}`) as requestData
        const newCom=result.data as commentType[]
        if (newCom.length>0) {
          this.commentList=newCom
          const indexdata=this.commentList.findIndex(i=>i.comment_id==this.locateData.target_comment_id)
          this.locateIndex=indexdata
          this.scroller.scrollToIndex(indexdata)
          setTimeout(()=>{
            this.locateIndex=-1
            this.goBug=false
          },1500)
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }
    }else if (this.locateData.comment_type=="reply" && this.goBug) {
      this.getPage=this.locateData.page
      try {
        const result=await qfsGet(`render/comment/${fid}?page=${this.getPage}`) as requestData
        const newCom=result.data as commentType[]
        if (newCom.length>0) {
          this.commentList=newCom
          const indexdata=this.commentList.findIndex(i=>i.comment_id==this.locateData.parent_comment_id)
          this.locateIndex=indexdata
          this.scroller.scrollToIndex(indexdata)
          setTimeout(()=>{
            this.locateIndex=-1
            this.goBug=false
          },1500)
          this.parentData=this.commentList.find(i=>i.comment_id==this.locateData.parent_comment_id) as commentType
          this.showChildren=true
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }
    }
    else {
      try {
        const result=await qfsGet(`render/comment/${fid}?page=${this.getPage}`) as requestData
        const newCom=result.data as commentType[]
        if (newCom.length>0) {
            const existingIds = new Set(this.commentList.map(c => String(c.comment_id)));
            const reallyNew = newCom.filter(c => !existingIds.has(String(c.comment_id)));
            this.commentList.push(...reallyNew);
        }else{
          this.DataIsNull=true
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }finally {
        this.getPageIsLogin=false
      }
    }
  }

  @State getPage:number=1
  @State getPageIsLogin:boolean=false
  @State DataIsNull:boolean=false



  @State parent_id:number|null=null
  @State reply_to_user_id:number|null=null
  async sendComment(){
    const body:postType={
      food_id:this.foodId,
      parent_id: this.parent_id,
      reply_to_user_id:this.reply_to_user_id,
      content:this.text
    }

    const result=await qfsPost(`send/comment`,body) as requestData
    const newCom=result.postedBy

    if(this.reply_to_user_id && result.code==200){
      wsManager.send(JSON.stringify({
        type: 'notification_num',
        payload:{
          parent_id:this.reply_to_user_id
        } as snf
      }));
    }
    this.parent_id=null
    this.reply_to_user_id=null
    this.getPage=1
    this.commentList=[]
    if (wsManager.getConnected()) {
      wsManager.send(JSON.stringify({
        type: 'notification_num',
        payload:{
          parent_id:newCom
        } as snf
      }));
    }
  }

  async toggleLike(comment: commentType) {
    const originalLiked = comment.is_liked;
    const originalCount = comment.like_count;

    comment.is_liked = comment.is_liked==1?0:1
    comment.like_count += comment.is_liked ? 1 : -1;
    this.refreshCommentList()

    try {
      const result=await qfsPost(`comment/${comment.comment_id}/like`) as requestData
      if (result.code !== 200) throw new Error('点赞失败');
    } catch (err) {
      comment.is_liked = originalLiked;
      comment.like_count = originalCount;
      this.refreshCommentList();
    }
  }

  private refreshCommentList() {
    this.commentList = [...this.commentList];
  }


  build() {
    NavDestination(){
      Column(){
        Text('评论区:')
          .fontSize(18)
          .padding({left:10})
          .width('100%')
          Column(){
            List({space:14,scroller:this.scroller}){
              ForEach(this.commentList,(i:commentType,index)=>{
                ListItem(){
                  Row({space:10}){
                    Image(i.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${i.avatar_url}`)
                      .size({width:40,height:40})
                      .borderRadius(5)
                    Column({space:5}){
                      Text(i.nickname)
                        .fontSize(18)
                        .fontColor('#ff707070')
                      Text(i.content)
                        .constraintSize({maxWidth:'70%'})
                        .fontSize(18)
                      Row({space:5}){
                        Text(formatTimeAgo(i.created_at))
                          .fontColor('#ff707070')
                          .fontSize(14)
                        Text('回复')
                          .fontSize(16)
                          .fontColor('#ff535252')
                          .onClick(()=>{
                            try {
                              this.uiContext.getFocusController().requestFocus('myInputV2');
                            } catch (error) {
                             console.error('[ztwjj]获取焦点失败')
                            }
                            this.parent_id=i.comment_id
                            this.reply_to_user_id=i.user_id
                            this.placeholderVal=`回复${i.nickname}`
                          })
                        SymbolGlyph($r('sys.symbol.heart_fill'))
                          .fontSize(20)
                          .fontColor([i.is_liked?'#ffff2525': '#ffe2e2e2'])
                          .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP),i.is_liked==1)
                          .onClick(()=>{
                           this.toggleLike(i)
                          })
                        Text(''+i.like_count)
                          .fontSize(16)
                          .fontColor('#ff535252')
                      }
                      if (i.reply_count>0) {
                        Row(){
                          Text(`——查看${i.reply_count}条评论`)
                            .fontColor('#ff707070')
                          SymbolGlyph($r('sys.symbol.indentation_left'))
                            .fontSize(20)
                            .fontColor(['#ff707070'])
                        }
                        //打开子评论模态框
                        .onClick(()=>{
                          this.parentData=i
                          this.showChildren=true
                        })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .backgroundColor(this.locateIndex==index?'#ffebf6d6':'')
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Top)
                  .padding({left:10})
                  .width('100%')
                }
              })
            }
            .height('60%')
            .width('100%')
            .margin({top:10})
            .onReachEnd(()=>{
              if (!this.getPageIsLogin && !this.DataIsNull){
                this.getPageIsLogin=true
                this.getPage+=1
                this.locateUtile(this.foodId)
              }
            })

            Row(){
              TextInput({placeholder:this.placeholderVal,text:$$this.text})
                .key('myInputV2')
                .onBlur(()=>{
                  this.parent_id=null
                  this.reply_to_user_id=null
                  this.placeholderVal='发表评论'
                })
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
                  if (this.text.trim()!=='' && this.text.trim().length<=120) {
                    this.sendComment()
                    this.text=''
                  }else if (this.text.trim().length>120) {
                    try{
                      this.uiContext?.getPromptAction().showToast({
                        message:'评论不能大于120字',
                        duration:1000
                      })
                    }catch (err){
                      return
                    }
                  }
                  else {
                    try{
                      this.uiContext?.getPromptAction().showToast({
                        message:'请输入内容',
                        duration:1000
                      })
                    }catch (err){
                      return
                    }
                  }
                })
            }
            .margin({top:10})
            .width('94%')
            .alignItems(VerticalAlign.Top)
          }

        }
        .margin({top:10})
        .backgroundColor(Color.White)
    }
    .transition(TransitionEffect.OPACITY.animation({curve:curves.springMotion(0.8,0.7)})
      .combine(TransitionEffect.translate({y:-100}))
    )
  }
}

@Component
export struct CommentChildrenDetail{
  @Prop getparent:commentType=new commentType()
  @Prop foodId:number
  @Link showChildren:boolean

  @State commentList:Array<commentType>=[]
  @State tishi:string=''
  @State text:string=''

  @Prop locateData:locateType
  @State locateIndex:number=-1
  private uiContext: UIContext = this.getUIContext();
  private scroller:Scroller=new Scroller()
  @State goBug:boolean=true

  aboutToAppear(): void {
    if (this.locateData.comment_type=="reply" && this.goBug) {
      this.locateUtile(this.locateData.parent_comment_id)
    }else {
      this.locateUtile(this.getparent.comment_id)
    }

    // console.log('[ztwjj],getparent:',JSON.stringify(this.getparent))
  }

  async locateUtile(fid:number){
    if (this.locateData.comment_type=="reply" && this.goBug) {
      this.getPage=this.locateData.page
      try {
        const result=await qfsGet(`comments/replies/${fid}?page=${this.getPage}`) as requestData
        const newCom=result.data as commentType[]
        if (newCom.length>0) {
          this.commentList=newCom
          const indexdata=this.commentList.findIndex(i=>i.comment_id==this.locateData.target_comment_id)
          this.locateIndex=indexdata
          this.scroller.scrollToIndex(indexdata)
          setTimeout(()=>{
            this.locateIndex=-1
            this.goBug=false
          },1500)
          this.showChildren=true
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }
    }
    else {
      try {
        const result=await qfsGet(`comments/replies/${fid}?page=${this.getPage}`) as requestData
        const newCom=result.data as commentType[]

        if (newCom.length>0) {
          const reallyNew = newCom.filter(
            item => !this.commentList.some(old => old.comment_id === item.comment_id)
          )
          this.commentList.push(...reallyNew)
        }else{
          this.DataIsNull=true
        }
      }catch (err){
        console.error('[ztwjj]',err)
      }finally {
        this.getPageIsLogin=false
      }
    }
  }

  @State getPage:number=1
  @State getPageIsLogin:boolean=false
  @State DataIsNull:boolean=false


  async sendComment(){
    const body:postType={
      food_id:this.foodId,
      parent_id: this.getparent.comment_id,
      reply_to_user_id:this.getparent.user_id,
      content:this.text
    }

    const result=await qfsPost(`send/comment`,body) as requestData
    const newCom=result.postedBy

    this.locateUtile(this.getparent.comment_id)
    if(this.getparent.user_id && result.code==200){
      wsManager.send(JSON.stringify({
        type: 'notification_num',
        payload:{
          parent_id:this.getparent.user_id
        } as snf
      }));
    }
    this.getPage=1
    this.commentList=[]
    if (wsManager.getConnected()) {
      wsManager.send(JSON.stringify({
        type: 'notification_num',
        payload:{
          parent_id:newCom
        } as snf
      }));
    }
  }

  build() {
    Column(){
      Column({space:5}){
        Row(){
          Text(`${this.getparent.reply_count}条评论 返回`)
            .fontColor('#ff707070')
          SymbolGlyph($r('sys.symbol.indent_right'))
            .fontSize(20)
            .fontColor(['#ff707070'])
        }
        .width('100%')
        .onClick(()=>{
          this.showChildren=false
        })
        Row({space:10}){
          Image(this.getparent.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${this.getparent.avatar_url}`)
            .size({width:40,height:40})
            .borderRadius(5)
          Column({space:5}){
            Text(this.getparent.nickname)
              .fontSize(18)
              .fontColor('#ff707070')
            Text(this.getparent.content)
              .constraintSize({maxWidth:'70%'})
              .fontSize(18)
            Row({space:5}){
              Text(formatTimeAgo(this.getparent.created_at))
                .fontColor('#ff707070')
                .fontSize(14)
             Text('点赞量:')
               .fontSize(14)
               .fontColor('#ff535252')
              Text(''+this.getparent.like_count)
                .fontSize(16)
                .fontColor('#ff535252')
            }

          }
          .alignItems(HorizontalAlign.Start)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .width('100%')

        Column(){
          List({space:10,scroller:this.scroller}){
            ForEach(this.commentList,(i:commentType,index)=>{
              ListItem(){
                Row({space:10}){
                  Image(i.avatar_url==null?$r('app.media.userimg'):`http://${myserverurl}:8080/uploads/${i.avatar_url}`)
                    .size({width:30,height:30})
                    .borderRadius(5)
                  Column({space:5}){
                    Text(i.nickname)
                      .fontSize(16)
                      .fontColor('#ff707070')
                    Text(i.content)
                      .constraintSize({maxWidth:'80%'})
                      .fontSize(16)
                    Row({space:5}){
                      Text(formatTimeAgo(i.created_at))
                        .fontColor('#ff707070')
                        .fontSize(14)
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Top)
                .width('90%')
                .margin({left:36})
              }
              .backgroundColor(this.locateIndex==index?'#ffebf6d6':'')
              .width('100%')
            })
          }
          .onReachEnd(()=>{
            if (!this.getPageIsLogin && !this.DataIsNull){
              this.getPageIsLogin=true
              this.getPage+=1
              this.locateUtile(this.getparent.comment_id)
            }
          })
          .width('100%')
          .height('84%')

          Row(){
            TextInput({placeholder:`回复${this.getparent.nickname}`,text:$$this.text})
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
                if (this.text.trim() && this.text.trim().length<=120) {
                  this.sendComment()
                  this.text=''
                }else if (this.text.trim().length>120) {
                  try{
                    this.uiContext?.getPromptAction().showToast({
                      message:'评论不能大于120字',
                      duration:1000
                    })
                  }catch (err){
                    return
                  }
                }
                else {
                  try{
                    this.uiContext?.getPromptAction().showToast({
                      message:'请输入内容',
                      duration:1000
                    })
                  }catch (err){
                    return
                  }
                }
              })
          }
          .width('94%')
          .alignItems(VerticalAlign.Top)
        }
        .size({width:'100%',height:'80%'})

      }
      .size({width:'80%',height:'84%'})
      .borderWidth(2)
      .backgroundColor(Color.White)
      .padding({top:10,left:10})
      .borderRadius({topLeft:10,bottomLeft:10})
      .onClick(()=>{})
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.End)
    .onClick(()=>{
      this.showChildren=false
    })
    .transition(TransitionEffect.OPACITY.animation({curve:curves.springMotion(0.4,0.5)})
      .combine(TransitionEffect.translate({x:50}))
    )
  }
}