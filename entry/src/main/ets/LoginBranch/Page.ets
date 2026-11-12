import { sha256 } from 'js-sha256';
import { http } from '@kit.NetworkKit'
import { router } from '@kit.ArkUI';

interface loginMsg{
  username:string
  password_hash:string
}
interface LoginResponsedata {
    role:string
    workshop_id:number
    username:string
}
interface LoginResponse {
  code: number
  msg: string
  token:string
  data:LoginResponsedata
}

export const myserverurl:string='10.36.116.220'
// export const myserverurl:string='10.34.18.229'

@Entry
@Component
struct Page {

  @State message: string = 'chengyou';
  @State password: string = 'cy123';
  @State tishi:string=''
  @State mima:string=''

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


  sendLogin(username:string,password_hash:string):Promise<LoginResponse>{
    return new Promise((resolve,reject)=>{
      const userMsgPost=http.createHttp()
      const LoginMsg:loginMsg={
        username:username,
        password_hash:sha256(password_hash).toUpperCase()
      }
      userMsgPost.request(
        `http://${myserverurl}:8080/user/Login`,
        {
          method:http.RequestMethod.POST,
          header:{
            "Content-Type":"application/json"
          },
          extraData:JSON.stringify(LoginMsg)
        },
        (err,data:http.HttpResponse)=>{
          const resData:LoginResponse=JSON.parse(data.result as string)
          resolve(resData)
        }
      )
    })
  }

  build() {
    Column() {

      Column(){
        Column(){
          Text('登录微食堂')
            .fontSize(32).fontWeight(FontWeight.Bold)
          Text('Login Micro Canteen')
            .fontSize(14).fontColor('#ffb8b8b8')
        }.width('100%')


        TextInput({placeholder:'用户名/手机号',text:$$this.message})
          .width('90%')
          .borderRadius(5)
          .backgroundColor(Color.White)
          .shadow({
            radius:8,
            color:'#33000000',
            offsetX:0,
            offsetY:2
          })
          .showError(this.tishi)
          .onChange(()=>{
            this.tishi=''
          })
        TextInput({placeholder:'密码',text:$$this.password })
          .type(InputType.Password)
          .showError(this.mima)
          .onChange(()=>{
            this.mima=''
          })
          .width('90%')
          .borderRadius(5)
          .backgroundColor(Color.White)
          .shadow({
            radius:8,
            color:'#33000000',
            offsetX:0,
            offsetY:2
          })
        Row(){
          Text('忘记密码?')
        }
        .justifyContent(FlexAlign.End)
        .width('90%')
        Row(){
          Button('登录',{type:ButtonType.Normal})
            .width('46%')
            .backgroundColor('#ff87ab09')
            .fontColor('#fff')
            .fontSize(20)
            .borderRadius(10)
            .onClick(async ()=>{
              if (this.message=='') {
                this.tishi='用户名不能为空'
                return
              }
              if (this.password=='') {
                this.mima='密码不能为空'
              }else if(!this.isUserAgreement){
                this.agreeDialog()
              }
              else{
                const resData=await this.sendLogin(this.message,this.password)
                this.loginDialog = new CustomDialogController({
                    builder: TextDialog({ message: resData.msg }),
                    autoCancel: true
                });
                this.loginDialog.open();
                  if(resData.code==200){
                    console.log('[ztwjj]token:',resData.token)
                    AppStorage.setOrCreate('authToken',resData.token)

                    AppStorage.setOrCreate('role',resData.data.role)

                    AppStorage.setOrCreate('User_workshop_id',resData.data.workshop_id)

                    AppStorage.setOrCreate('User_username',resData.data.username)

                    router.replaceUrl({
                      url:'pages/main'
                    })
                  }
              }
            })
          Button('注册',{type:ButtonType.Normal})
            .width('46%')
            .backgroundColor('#ffcacaca')
            .fontColor('#fff')
            .fontSize(20)
            .borderRadius(8)
            .onClick(()=>{
              router.pushUrl({
                url:'LoginBranch/signUp'
              })
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('90%')

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
      .backgroundColor('#fff')
      .borderRadius(10)
      .shadow({
        radius:8,
        offsetY:8,
        color:'#666'
      })
      .justifyContent(FlexAlign.SpaceAround)
      .width('90%')
      .height('50%')
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor('#fff')
  }

  private loginDialog: CustomDialogController = new CustomDialogController({
    builder: TextDialog({ message: '' }),
    autoCancel: true,
    customStyle: true
  });
}

@CustomDialog
struct TextDialog {
  controller: CustomDialogController;
  message: string = '';

  build() {
    Column({space:20}) {
      Text(this.message)
        .padding({top:10,left:12})
        .fontSize(24)
      Button('确定')
        .backgroundColor('rgba(255,255,255,0)')
        .fontColor('#ff8cbf30')
        .onClick(() => {
          this.controller.close();
        })
    }
  }
}