import webSocket from '@ohos.net.webSocket';
import emitter from '@ohos.events.emitter';

const WSMESSAGE_EVENT_ID = 1;

class WebSocketManager {

  private static instance: WebSocketManager;
  private ws: webSocket.WebSocket | null = null;
  private isConnected: boolean = false;
  private constructor() {}

  static getInstance(): WebSocketManager {
    if (!WebSocketManager.instance) {
      WebSocketManager.instance = new WebSocketManager();
    }
    return WebSocketManager.instance;
  }

  // 初始化WebSocket连接
  init(url: string) {
    if (this.ws) return;
    this.ws = webSocket.createWebSocket();

    this.ws.connect(url, (err, value) => {
      if (!err) console.log('[ztwjj]WebSocket 连接请求已发送');
    });

    this.ws.on('open', (err, value) => {
      if (!err) this.isConnected = true;
    });

    this.ws.on('message', (err, value) => {
      if (!err) {
        const eventData: emitter.EventData = {
          data: { "wsMessage": value }
        };
        const innerEvent: emitter.InnerEvent = {
          eventId: WSMESSAGE_EVENT_ID,
          priority: emitter.EventPriority.HIGH
        };
        emitter.emit(innerEvent, eventData);

      }
    });

    this.ws.on('close', (err, value) => { this.isConnected = false; });
    this.ws.on('error', (err) => { this.isConnected = false; });
  }


  send(data: string | ArrayBuffer) {
    if (this.ws && this.isConnected) {
      this.ws.send(data, (err, value) => {
        if (err) console.error('[ztwjj]消息发送失败:', JSON.stringify(err));
      });
    }
  }

  close(){
    if(this.ws){
      this.ws.close((err,value)=>{
        if(!err){
          console.log('[ztwjj]ws已主动关闭')
          this.ws=null
          this.isConnected=false
        }else {
          console.error('[ztwjj]ws关闭失败：',err)
        }
      })
    }
  }


  getConnected(): boolean { return this.isConnected; }
}


export const wsManager = WebSocketManager.getInstance();
