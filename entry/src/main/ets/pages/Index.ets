import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = '这是加载页面';
  @State nub:number=6
  loading?:number
  @State isVideo:boolean=false

  aboutToAppear(): void {



    this.loading=setInterval(()=>{
      if (this.nub==1) {
        // this.gotoLogin()
      }else if (this.nub==0){
        return
      }
      this.nub-=1
    },1000)
  }

  gotoLogin(){
    router.replaceUrl({ url:'LoginBranch/Page' })
  }

  aboutToDisappear(): void {
    clearInterval(this.loading)
  }

  build() {
    Stack(){
      if(!this.isVideo){
        Column().size({width:'100%',height:'100%'}).backgroundColor(Color.White)
      }

      Column(){
        Video({src:$rawfile('start_animation.mp4')})
          .size({width:'100%',height:'100%'})
          .autoPlay(true)
          .controls(false)
          .onFinish(()=>this.gotoLogin())
          .opacity(this.isVideo?1:0)
          .onPrepared(()=>setTimeout(()=>{this.isVideo=true},300))
      }
      .justifyContent(FlexAlign.Center)
      .size({width:'100%',height:'100%'})

      Column(){
        Row(){
          Text(this.nub+'秒')
          Button('跳过',{type:ButtonType.Normal}).type(ButtonType.Normal).backgroundColor(Color.Transparent)
            .fontColor(Color.Black)
            .onClick(()=>{
              this.gotoLogin()
              clearInterval(this.loading)
            })
        }
        .width('96%')
        .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)
        .visibility(this.isVideo?Visibility.Visible:Visibility.None)
      }.size({width:'100%',height:'100%'}).justifyContent(FlexAlign.Start)

    }
    .backgroundColor('#FFF8F1')
    .height('100%')
    .width('100%')
  }
}