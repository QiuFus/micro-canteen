// utils/PictureService.ets
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { request } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

interface bodytype{ code: number; msg: string; url: string }
interface packType{
  upUrl:string
  imgUrl:string
}

class PictureService {
  private static instance: PictureService;
  private context?: common.Context;

  private constructor() {}

  static getInstance(): PictureService {
    if (!PictureService.instance) {
      PictureService.instance = new PictureService();
    }
    return PictureService.instance;
  }

  setContext(ctx: common.Context) {
    this.context = ctx;
  }

  //从相册选择图片
  async selectFromGallery(maxCount: number = 1): Promise<string[]> {
    const opt = new photoAccessHelper.PhotoSelectOptions();
    opt.maxSelectNumber = maxCount;
    opt.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    const picker = new photoAccessHelper.PhotoViewPicker();
    try {
      const result = await picker.select(opt);
      return result.photoUris;
    } catch (err) {
      console.error('[ztwjj]选择图片失败:', JSON.stringify(err));
      return [];
    }
  }

  //压缩图片到沙箱
  async compressToCache(uri: string): Promise<packType> {
    const fileName = `compressed_${Date.now()}.jpg`;
    const destPath = `${this.context?.cacheDir}/${fileName}`;
    let srcFile: fs.File | null = null;
    let destFile: fs.File | null = null;
    try {
      srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const imageSource = image.createImageSource(srcFile.fd);
      const packer = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 70 };
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      await packer.packToFile(imageSource, destFile.fd, packOpts);
      imageSource.release();
      packer.release();
      return {upUrl:`internal://cache/${fileName}`,imgUrl:`file://${destPath}`};
    } catch (err) {
      console.error('[ztwjj]压缩图片失败:', JSON.stringify(err));
      return {upUrl:'',imgUrl:''};
    } finally {
      // 确保文件描述符被关闭
      if (srcFile) fs.closeSync(srcFile);
      if (destFile) fs.closeSync(destFile);
    }
  }

  //上传图片到服务器
  async uploadImage(sandboxUri: string, uploadUrl: string): Promise<string|null> {
    try {
      if (!this.context) {
        console.error('[ztwjj]PictureService: context 未初始化');
        return '';
      }
      if(!sandboxUri) return null
      const result = await request.uploadFile(this.context, {
        url: uploadUrl,
        method: 'POST',
        header: { 'Content-Type': 'multipart/form-data' },
        files: [{ filename: 'file', name: 'file', uri: sandboxUri, type: 'image/jpeg' }],
        data: [],
      });
      return new Promise((resolve, reject) => {
        result.on('headerReceive', (headers: object) => {
          try {
            // 服务器返回的响应体会被放在 headers 的 body 字段中
            const headersObj = JSON.parse(JSON.stringify(headers)) as Record<string, string>;
            const bodyStr = headersObj['body'] as string;
            if (bodyStr) {
              const response = JSON.parse(bodyStr) as bodytype;
              console.log('[ztwjj] 服务器返回:', JSON.stringify(response));
              resolve(response.url);
            } else {
              reject(new Error('headerReceive 中未找到 body 字段'));
            }
          } catch (parseErr) {
            reject(new Error('解析 headerReceive 数据失败: ' + JSON.stringify(parseErr)));
          }
        });
        result.on('fail', (e) => reject(new Error(JSON.stringify(e))));
      });
    } catch (err) {
      console.error('[ztwjj]上传图片失败:', JSON.stringify(err));
      return null;
    }
  }

  //选择、压缩并上传
  async selectAndUpload(uploadUrl: string): Promise<string|null> {
    const uris = await this.selectFromGallery(1);
    if (!uris || uris.length === 0) return '';

    const compressedUri = await this.compressToCache(uris[0]);
    if (!compressedUri) return '';

    return this.uploadImage(compressedUri.upUrl, uploadUrl);
  }
}

export const pictureService = PictureService.getInstance();