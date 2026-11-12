import { curves, SymbolGlyphModifier } from "@kit.ArkUI"

import { qfsGet, qfsPost, qfsPut } from "../utils/httpRequest"
import { setFoodDetailType, requestData } from "../pages/main"
import { myserverurl } from "../LoginBranch/Page"
import { pictureService } from "../utils/PictureService"

interface packType{ upUrl:string,imgUrl:string }
interface putTtype{ s_img:string, schoolId:number, c_img:string, c_description:string, canteenId:number,
w_img:string, w_description:string, workshopId:number, foodName:string, imageUrl:string, description:string, foodId:number}

interface postType{ workshopId:number,w_description:string,w_img:string, foodName:string, imageUrl:string, description:string }


@Component
struct setFoodDetail{

  @State foodData:setFoodDetailType=new setFoodDetailType()

  @State foodId:number=-1
  private pageStack:NavPathStack=new NavPathStack()
  private role=AppStorage.get('role') as string
  private workId=AppStorage.get('User_workshop_id') as number
  private deleteDal: CustomDialogController = new CustomDialogController({
    builder: isdelete({deletef:()=>{},message:'',val:'',colzhi:''}),
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear(): void {

    if (this.foodId==-1) {
      this.addData()
    }else {
      this.getFoodDetail(this.foodId)
    }
  }

  async getFoodDetail(food_id:number){
    try {
      const result=await qfsGet(`setFood/detail/${food_id}`) as requestData
      this.foodData=result.data as setFoodDetailType

      this.text_province=this.foodData.province
      this.text_city=this.foodData.city
      this.text_district=this.foodData.district
      this.school_name=this.foodData.school_name

      this.c_name=this.foodData.c_name
      this.c_description=this.foodData.c_description

      this.w_name=this.foodData.w_name
      this.w_description=this.foodData.w_description

      this.f_name=this.foodData.f_name
      this.f_description=this.foodData.f_description
    }catch(err){
      console.error('[ztwjj]',err)
    }
  }

  async addData(){
    try {
      const result=await qfsGet(`getAddData/${this.workId}`) as requestData
      this.foodData=result.data as setFoodDetailType

      this.text_province=this.foodData.province
      this.text_city=this.foodData.city
      this.text_district=this.foodData.district
      this.school_name=this.foodData.school_name

      this.c_name=this.foodData.c_name
      this.c_description=this.foodData.c_description

      this.w_name=this.foodData.w_name
      this.w_description=this.foodData.w_description
    }catch(err){
      console.error('[ztwjj]',err)
    }
  }

  @State text_province:string=''
  @State text_city:string=''
  @State text_district:string=''
  @State school_name:string=''
  @State s_img:string=''

  @State c_name:string=''
  @State c_img:string=''
  @State c_description:string=''

  @State w_name:string=''
  @State w_img:string=''
  @State w_description:string=''

  @State f_name:string=''
  @State f_img:string=''
  @State f_description:string=''

  @State save_s_img:string=''
  @State save_c_img:string=''
  @State save_w_img:string=''
  @State save_f_img:string=''

  build() {
    NavDestination(){
      Scroll(){
        Column({space:10}){

          Row({space:4}){
            Text('省份：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入省份',text:$$this.text_province})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(120)
              .enabled((this.role=='admin' && this.foodId!==-1)?true:false)
          }

          Row({space:4}) {
            Text('城市：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({ placeholder: '请输入城市', text: $$this.text_city })
              .backgroundColor(Color.White)
              .borderRadius(0)
              .borderWidth({ bottom: 1 })
              .borderColor('#ffa0a0a0')
              .width(120)
              .enabled((this.role=='admin' && this.foodId!==-1) ? true : false)
          }

          Row({space:4}){
            Text('区县：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入区县',text:$$this.text_district})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(120)
              .enabled((this.role=='admin' && this.foodId!==-1)?true:false)
          }

          Row({space:8}){
            Text('学校：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入学校',text:$$this.school_name})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
              .enabled((this.role=='admin' && this.foodId!==-1)?true:false)
          }
          Text('学校图片：')
          Stack(){
            Image($r('app.media.unloadImg'))
              .size({width:'90%',height:200})
            Image(this.s_img==''?(this.foodData.s_img==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${this.foodData.s_img}`):this.s_img)
              .size({width:'90%',height:200})
              .onClick(async ()=>{

                if (this.role=='admin') {
                  if (this.foodId==-1) {
                    this.deleteDal= new CustomDialogController({
                      builder: isdelete({message:'添加菜品时,此信息只做参考',val:'确定',colzhi:'#ff8cbf30'}),
                      autoCancel: true
                    });
                    this.deleteDal.open()
                  }else {
                    const newUrl=await this.selectImg()
                    this.s_img=newUrl.imgUrl
                    this.save_s_img=newUrl.upUrl
                  }
                }else {
                  this.deleteDal= new CustomDialogController({
                    builder: isdelete({message:'只有管理员才能修改食堂及以上级别的信息哦',val:'确定',colzhi:'#ff8cbf30'}),
                    autoCancel: true
                  });
                  this.deleteDal.open()
                }
              })
          }

          Row({space:8}){
            Text('食堂：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入食堂名称',text:$$this.c_name})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
              .enabled((this.role=='admin' && this.foodId!==-1)?true:false)
          }
          Row({space:10}){
            Column({space:4}){
              Text('食堂图片：')
              Stack(){
                Image($r('app.media.unloadImg'))
                  .size({width:180,height:140})
                Image(this.c_img==''?(this.foodData.c_img==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${this.foodData.c_img}`):this.c_img)
                  .size({width:180,height:140})
                  .onClick(async()=>{
                    if (this.role=='admin') {
                      if (this.foodId==-1) {
                        this.deleteDal= new CustomDialogController({
                          builder: isdelete({message:'添加菜品时,此信息只做参考',val:'确定',colzhi:'#ff8cbf30'}),
                          autoCancel: true
                        });
                        this.deleteDal.open()
                      }else {
                        const newUrl=await this.selectImg()
                        this.c_img=newUrl.imgUrl
                        this.save_c_img=newUrl.upUrl
                      }
                    }else {
                      this.deleteDal= new CustomDialogController({
                        builder: isdelete({message:'只有管理员才能修改食堂及以上级别的信息哦',val:'确定',colzhi:'#ff8cbf30'}),
                        autoCancel: true
                      });
                      this.deleteDal.open()
                    }
                  })
              }

            }.alignItems(HorizontalAlign.Start)
            Column({space:4}){
              Text('食堂详情：')
              TextArea({placeholder:'请输入食堂简介...',text:$$this.c_description})
                .maxLines(5).size({width:140,height:140}).borderRadius(5)
                .enabled((this.role=='admin' && this.foodId!==-1)?true:false)
            }.alignItems(HorizontalAlign.Start)
          }

          Row({space:8}){
            Text('作坊：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入作坊名称',text:$$this.w_name})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
          }
          Row({space:10}){
            Column({space:4}){
              Text('作坊图片：')
              Stack(){
                Image($r('app.media.unloadImg'))
                  .size({width:180,height:140})
                Image(this.w_img==''?(this.foodData.w_img==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${this.foodData.w_img}`):this.w_img)
                  .size({width:180,height:140})
                  .onClick(async()=>{
                    const newUrl=await this.selectImg()
                    this.w_img=newUrl.imgUrl
                    this.save_w_img=newUrl.upUrl
                  })
              }
            }.alignItems(HorizontalAlign.Start)
            Column({space:4}){
              Text('作坊详情：')
              TextArea({placeholder:'请输入作坊简介...',text:$$this.w_description})
                .maxLines(5).size({width:140,height:140}).borderRadius(5)
            }.alignItems(HorizontalAlign.Start)
          }

          Row({space:8}){
            Text('菜品：').fontSize(20).fontWeight(FontWeight.Bold)
            TextInput({placeholder:'请输入菜品名称',text:$$this.f_name})
              .backgroundColor(Color.White).borderRadius(0)
              .borderWidth({bottom:1}).borderColor('#ffa0a0a0').width(240)
          }
          Text('菜品图片：')
          Stack(){
            Image($r('app.media.unloadImg'))
              .size({width:'90%',height:200})
            Image(this.f_img==''?(this.foodData.f_img==null?$r('app.media.unloadImg'):`http://${myserverurl}:8080/uploads/${this.foodData.f_img}`):this.f_img)
              .size({width:'90%',height:200})
              .onClick(async()=>{
                const newUrl=await this.selectImg()
                this.f_img=newUrl.imgUrl
                this.save_f_img=newUrl.upUrl
              })
          }
          Text('菜品详情：')
          TextArea({placeholder:'描述一下这道菜吧...',text:$$this.f_description})
            .maxLines(5).size({width:'90%',height:200}).borderRadius(5)

        }
        .alignItems(HorizontalAlign.Start)
        .size({width:'100%'})
      }
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.4)
      .padding(20)
      .size({width:'100%',height:'100%'})
      .transition(TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({x:100}))
      )
    }
    .onReady((ctx:NavDestinationContext)=>{
      this.pageStack=ctx.pathStack
    })
    .title('设置菜品信息')
    .backgroundColor(Color.White)
    .menus([
      {
        value: 'save',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark'))
          .fontWeight(FontWeight.Bold),
        action: () => {
          if (this.foodId==-1) {
            this.deleteDal= new CustomDialogController({
              builder: isdelete({deletef:async ()=>{
                await this.newAddFood()
              },message:'确定准备上传的数据无误吗?',val:'确定',colzhi:'#ff8cbf30'}),
              autoCancel: true
            });
            this.deleteDal.open()
          }else {
            this.deleteDal= new CustomDialogController({
              builder: isdelete({deletef:async ()=>{
                await this.savePutSetFood()
              },message:'确定要上传更改的数据吗?',val:'确定',colzhi:'#ff8cbf30'}),
              autoCancel: true
            });
            this.deleteDal.open()
          }
        }
      }
    ])
  }

  async selectImg():Promise<packType>{
    const uris = await pictureService.selectFromGallery(1);
    if (!uris || uris.length === 0) return {upUrl:'',imgUrl:''};

    const compressedUri = await pictureService.compressToCache(uris[0]);
    if (!compressedUri) return {upUrl:'',imgUrl:''};

    return {upUrl:compressedUri.upUrl,imgUrl:compressedUri.imgUrl}
  }

  async newAddFood(){
    const uploadUrl = `http://${myserverurl}:8080/upload`;
    const results = await Promise.all([
      pictureService.uploadImage(this.save_w_img, uploadUrl),
      pictureService.uploadImage(this.save_f_img, uploadUrl)
    ]);
    const wImg = results[0] || '';
    const fImg = results[1] || '';

    this.foodData.w_img = wImg;
    this.foodData.f_img = fImg;

    try {
      const postBody:postType={
        workshopId:this.workId,w_img:this.foodData.w_img, w_description:this.w_description,
        foodName:this.f_name, imageUrl:this.foodData.f_img, description:this.f_description
      }
      const result=await qfsPost(`foods/publish`,postBody) as requestData
      this.deleteDal= new CustomDialogController({
        builder: isdelete({message:result.msg,val:'确定',colzhi:'#ff8cbf30'}),
        autoCancel: true
      });
      this.deleteDal.open()
      this.pageStack.pop()
    }catch (err){
      console.warn('[ztwjj]数据上传失败')
    }
  }

  async savePutSetFood(){
    const uploadUrl = `http://${myserverurl}:8080/upload`;
    const results = await Promise.all([
      pictureService.uploadImage(this.save_s_img, uploadUrl),
      pictureService.uploadImage(this.save_c_img, uploadUrl),
      pictureService.uploadImage(this.save_w_img, uploadUrl),
      pictureService.uploadImage(this.save_f_img, uploadUrl)
    ]);

    const sImg = results[0] || this.foodData.s_img;
    const cImg = results[1] || this.foodData.c_img;
    const wImg = results[2] || this.foodData.w_img ;
    const fImg = results[3] || this.foodData.f_img;

    this.foodData.s_img = sImg;
    this.foodData.c_img = cImg;
    this.foodData.w_img = wImg;
    this.foodData.f_img = fImg;

    if (!sImg || !cImg || !wImg || !fImg) {
      console.warn('有图片为空');
    }
    try {
      const putBody:putTtype={
        s_img:this.foodData.s_img, schoolId:this.foodData.school_id, c_img:this.foodData.c_img, c_description:this.c_description,
        canteenId:this.foodData.canteen_id, w_img:this.foodData.w_img, w_description:this.w_description, workshopId:this.foodData.workshop_id,
        foodName:this.f_name, imageUrl:this.foodData.f_img, description:this.f_description, foodId:this.foodId
      }
      const result=await qfsPut(`put/sent_food`,putBody) as requestData
      this.deleteDal= new CustomDialogController({
        builder: isdelete({message:result.msg,val:'确定',colzhi:'#ff8cbf30'}),
        autoCancel: true
      });
      this.deleteDal.open()
      this.pageStack.pop()
    }catch (err){
      console.log('[ztwjj]数据修改失败')
    }

  }

}

@Builder
export function setFoodDetailBuilder(name:string,id:number){
  setFoodDetail({foodId:id})
}

@CustomDialog
struct isdelete {
  onisdelete: CustomDialogController;
  message:string=''
  val:string=''
  colzhi:string=''
  deletef?:()=>void

  build() {
    Column({space:10}) {
      Text(this.message)
        .padding({top:16,left:12})
        .fontSize(24)
      Row(){
        Button(this.val)
          .backgroundColor('rgba(255,255,255,0)')
          .fontColor(this.colzhi)
          .onClick(() => {
            if (this.deletef) {
              this.deletef()
            }
            this.onisdelete.close();
          })
        Button('取消')
          .backgroundColor('rgba(255,255,255,0)')
          .fontColor(Color.Black)
          .onClick(()=>{
            this.onisdelete.close();
          })
      }
    }
  }
}