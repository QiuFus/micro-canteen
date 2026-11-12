import { curves } from "@kit.ArkUI"
import { qfsGet } from "../utils/httpRequest";

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
  subDetail: string
}
@Component
struct MySearch{
  pageState:NavPathStack=new NavPathStack()

  @State showbool: boolean=true
  @State placeholderText: string = '';
  @State searchText: string = ''
  @State showCursor: boolean = true;
  @State showDropdown: boolean = false // 控制下拉列表显示/隐藏

  @State allFoods: searchType[] =[]
  @State filteredFoods: string[] = []
  private timer: number = -1;
  private Cursor: number = -1;

  aboutToAppear(): void {

    setTimeout(()=>{
      this.animateRun()
      this.startTyping()
    },16)

  }

  aboutToDisappear() {
    clearInterval(this.timer)
    clearInterval(this.Cursor)
  }

  startTyping() {
    let fullText: string = '搜索学校，地域';
    let index: number = 0;

    this.Cursor=setInterval(()=>{
      this.showCursor=!this.showCursor
    },500)

    this.timer = setInterval(() => {
      if (index < fullText.length) {
        index++;
        this.placeholderText = fullText.substring(0, index)+(this.showCursor ? '|' : '');
      } else {
        clearInterval(this.timer);
        clearInterval(this.Cursor)
        this.placeholderText = fullText
      }
    }, 150);
  }

  animateRun(){
    this.getUIContext()?.animateTo({
      curve:curves.springMotion(0.7,0.8)
    },()=>{
      this.showbool=!this.showbool
    })
  }

  async filterData(keyword: string) {
    if (!keyword) {
      this.filteredFoods = []
      return;
    }
    const result=await qfsGet(`search/suggest?q=${encodeURIComponent(keyword)}`) as requestData
    const list=result.data as searchType[]
    let newlist=this.abc(list,keyword)
    this.filteredFoods=newlist
    this.showDropdown=this.filteredFoods.length>0
  }

   abc(x:searchType[],vo:string):string[]{
    const list=x.flatMap(i=>[i.name.trim(),i.detail.trim(),i.subDetail.trim()])
      .filter(i=>i.length>0&&i.includes(vo))
    const newlist= new Set(list)
    return Array.from(newlist)
  }


  build() {
    NavDestination(){
      if (this.showbool){
        Row(){
          Blank()
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({right:24})
            .geometryTransition(`mysearch`)
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .transition(TransitionEffect.OPACITY
              .combine(TransitionEffect.translate({y:-50}))
            )
        }
        .width('100%')
        .padding({right:24,top:6})
        .height(50)
      }


      Column(){
        Row() {
          if (!this.showbool){
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .padding({left:10})
              .height(40)
              .geometryTransition(`mysearch`)
              .onClick(()=>{
                if (this.searchText.trim()=='') return
                this.pageState.pushPathByName('SearchDetail',this.searchText,false)
              })
          }

          TextInput({ placeholder:this.placeholderText,text: $$this.searchText})
            .defaultFocus(true)
            .width('90%')
            .height(40)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.filterData(value);
            })
            .onFocus(() => {
              this.showDropdown = true
            })
        }
        .width('80%')
        .borderRadius(5)
        .borderWidth(2)

        if (this.showDropdown && this.filteredFoods.length > 0) {
          List() {
            ForEach(this.filteredFoods, (item: string) => {
              ListItem() {
                Row(){
                  Text(item)
                    .fontSize(18)
                    .padding(12)
                    .maxLines(1)
                    .constraintSize({maxWidth:'70%'})
                    .textOverflow({overflow:TextOverflow.Ellipsis})
                  Blank()
                  SymbolGlyph($r('sys.symbol.arrow_up_left'))
                    .fontSize(24)
                    .margin({right:16})
                    .height(40)
                }
                .width('100%')
                .onClick(() => {
                  this.searchText = item;
                  setTimeout(()=>{
                    this.showDropdown = false;
                  },50)
                  setTimeout(()=>{
                    this.pageState.pushPathByName('SearchDetail',item,false)
                  },150)
                })
              }
              .backgroundColor(Color.White)
              .border({ width: { bottom: 0.5 }, color: '#ffcdcdcd' })
            })
          }
          .width('80%')
          .height(Math.min(this.filteredFoods.length * 48, 600))
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({ radius: 8, color: '#00000020' })
        }
      }
      .width('100%')

    }
    .onReady((ctx:NavDestinationContext)=>{
      this.pageState=ctx.pathStack
    })
    .hideTitleBar(this.showbool)
    .height('100%')
    .width('100%')
  }
}

@Builder
export function MySearchBuilder(){
  MySearch()
}