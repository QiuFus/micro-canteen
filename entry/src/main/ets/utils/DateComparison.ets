function parseBackendTime(timeStr: string): Date {
  // 将空格替换为 'T'，兼容 iOS/Android 所有设备
  return new Date(timeStr.replace(' ', 'T'));
}

export function formatTimeAgo(timeStr: string): string {
  const backendDate = parseBackendTime(timeStr);
  const now = new Date();
  const diffMs = now.getTime() - backendDate.getTime();
  const diffSeconds = Math.floor(diffMs / 1000);
  const diffMinutes = Math.floor(diffSeconds / 60);
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffHours / 24);

  // 刚刚（小于 30 秒）
  if (diffSeconds < 30) {
    return '刚刚';
  }
  // 1 分钟内
  if (diffSeconds < 60) {
    return `${diffSeconds}秒前`;
  }
  // 1 小时内
  if (diffMinutes < 60) {
    return `${diffMinutes}分钟前`;
  }
  // 24 小时内
  if (diffHours < 24) {
    return `${diffHours}小时前`;
  }
  // 超过 24 小时，显示具体日期
  const year = backendDate.getFullYear();
  const month = backendDate.getMonth() + 1;
  const day = backendDate.getDate();
  const hour = backendDate.getHours().toString().padStart(2, '0');
  const minute = backendDate.getMinutes().toString().padStart(2, '0');

  // 判断是否是今年
  if (year === now.getFullYear()) {
    if (diffDays === 1) {
      return `昨天 ${hour}:${minute}`;
    }
    if (diffDays === 2) {
      return `前天 ${hour}:${minute}`;
    }
    return `${month}/${day} ${hour}:${minute}`;
  }
  return `${year}/${month}/${day} ${hour}:${minute}`;
}