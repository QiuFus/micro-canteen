import { router } from '@kit.ArkUI'

@Entry
@Component
struct SignUp {
  @State username:string=''
  @State userPasseord:string=''
  @State checkNum:number|null=null
  @State countDown:number=60
  @State isCheck:boolean=false
  countDownSet?:number


  checkFc(){
    this.isCheck=true
    this.countDownSet=setInterval(()=>{
      this.countDown-=1
      if(this.countDown<1){
        this.isCheck=false
        clearInterval(this.countDownSet)
        this.countDown=60
      }
    },1000)
  }

  aboutToDisappear(): void {
    if(this.countDownSet){
      clearInterval(this.countDownSet)
    }
  }

  userAgreement(){
    const text='平台仅开放账号使用权，出现违规使用情形时，平台可以收回账号使用资格'
    this.showAlertDialog('用户协议',text)
  }
  privacyPolicy(){
    const text='本平台仅搜集业务必须的用户基础信息，绝不泄漏任何数据，仅用于功能正常运行'
    this.showAlertDialog('隐私政策',text)
  }
  agreeDialog(){
    const text='请勾选用户协议'
    this.showAlertDialog('',text)
  }
  showAlertDialog(title:string,msg:string){
    AlertDialog.show({
      title:title,
      message:msg,
      confirm:{
        value:'确定',
        fontColor:'#ff87ab09',
        action:()=>{}
      }
    })
  }
  @State isUserAgreement:boolean=false

  build() {
    RelativeContainer() {

      Row(){
        SymbolGlyph($r('sys.symbol.arrow_left')).fontSize(36).fontColor(['#ff647e08'])
          .fontWeight(FontWeight.Bold)
          .onClick(()=>{
            router.back()
          })
      }.width('100%').justifyContent(FlexAlign.Start).padding(20)

      Column({space:20}){
        Column().height('8%')

        Text('注册').fontSize(36).fontColor(Color.White).textAlign(TextAlign.Start).width('100%')
          .fontWeight(FontWeight.Bold)

        Row({space:10}){
          SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
            .fontSize(30).fontColor(['#fff'])
          TextInput({placeholder:'输入手机号',text:$$this.username}).layoutWeight(1).padding({left:10})
            .placeholderColor('#fff').backgroundColor(Color.Transparent)
            .fontColor('#fff')
        }.padding(10).borderRadius(10).backgroundColor('#ff759409')

        Row({space:10}){
          TextInput({placeholder:'输入验证码',text:$$this.checkNum}).layoutWeight(1).padding({left:10})
            .placeholderColor('#fff').backgroundColor(Color.Transparent)
            .fontColor('#fff')
          Button(this.isCheck?`${this.countDown}秒后重试`:`获取验证码`).type(ButtonType.Normal).backgroundColor('#ccc').fontColor('#fff')
            .borderRadius(5)
            .onClick(()=>{
              if(!this.username.trim() || this.username.length<11){
                AlertDialog.show({
                  message:this.username.length<11 && this.username.trim()?'手机号无效':'请输入手机号',
                  confirm:{
                    value:'确定',
                    fontColor:'#ff759409',
                    action:()=>{}
                  }
                })
              }else {
                this.checkFc()
              }
            })
        }.padding(10).borderRadius(10).backgroundColor('#ff759409')

        Row({space:10}){
          SymbolGlyph($r('sys.symbol.lock_fill'))
            .fontSize(26).fontColor(['#fff'])
          TextInput({placeholder:'输入密码',text:$$this.userPasseord}).layoutWeight(1).padding({left:10})
            .placeholderColor('#fff').type(InputType.Password)
            .fontColor('#fff').backgroundColor(Color.Transparent)
        }.padding(10).borderRadius(10).backgroundColor('#ff759409')

        Button('注册').type(ButtonType.Normal).backgroundColor('#ffe0fc76')
          .fontColor('#ff87ab09').width('90%').fontSize(22).fontWeight(FontWeight.Bold)
          .borderRadius(5)
          .onClick(()=>{
            if(!this.checkNum?.toString().trim()){
              this.showAlertDialog('','请输入验证码')
            }else if(!this.isUserAgreement){
              this.agreeDialog()
            }else if(!this.username.trim()||!this.userPasseord.trim()){
              this.showAlertDialog('','账号或密码不能为空')
            }else {
              this.showAlertDialog('','验证码无效')
            }
          })

        Row(){
          Checkbox()
            .onClick(()=>this.isUserAgreement=!this.isUserAgreement)
            .selectedColor('#ff0983c4').width(16)
          Text('我已阅读并同意《').fontSize(14)
          Text('用户协议').fontColor('#ff0983c4').borderWidth({bottom:1}).borderColor('#ff0983c4').fontSize(14)
            .onClick(()=>this.userAgreement())
          Text('》和《').fontSize(14)
          Text('隐私政策').fontColor('#ff0983c4').borderWidth({bottom:1}).borderColor('#ff0983c4').fontSize(14)
            .onClick(()=>this.privacyPolicy())
          Text('》').fontSize(14)
        }
      }
      .size({width:'100%',height:'86%'})
      .padding(20)
      .backgroundColor('#ff87ab09')
      .linearGradient({
        direction:GradientDirection.Top,
        colors:[
          ['#ff87ab09',0.6],
          ['#ffe3f699',1.0],
        ]
      })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })


    }
    .height('100%')
    .width('100%')
    .backgroundColor('#ffe3f699')
  }
}