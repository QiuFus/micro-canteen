import { http } from '@kit.NetworkKit';
import { myserverurl } from '../LoginBranch/Page';

const httpClient = http.createHttp();

function getToken(): string {
  return (AppStorage.get('authToken') as string) || '';
}

function request(
  method: http.RequestMethod,
  url: string,
  body?: object
): Promise<object> {
  return new Promise((resolve, reject) => {
    const headers: Record<string, string> = {
      'Authorization': `Bearer ${getToken()}`
    };
    if (body) {
      headers['Content-Type'] = 'application/json';
    }

    httpClient.request(
      `http://${myserverurl}:8080/user/${url}`,
      {
        method,
        header: headers,
        extraData: body ? JSON.stringify(body) : undefined
      },
      (err, data: http.HttpResponse) => {
        if (err) {
          console.error(`[ztwjj] ${method} ${url} 失败:`, err.message);
          return reject(err);
        }
        try {
          const result = JSON.parse(data.result as string) as object
          resolve(result);
        } catch {
          console.error('[ztwjj]网络请求失败：',err)
          resolve(data.result as object);
        }
      }
    );
  });
}

export function qfsGet(url: string): Promise<object> {
  return request(http.RequestMethod.GET, url);
}

export function qfsPost(url: string, body?: object): Promise<object> {
  return request(http.RequestMethod.POST, url, body);
}

export function qfsPut(url: string, body?: object): Promise<object> {
  return request(http.RequestMethod.PUT, url, body);
}

export function qfsDelete(url: string,body?:object): Promise<object> {
  return request(http.RequestMethod.DELETE, url,body);
}
