// 根据环境自动判断API地址
// 开发环境：使用localhost
// 生产环境：使用相对路径，由nginx代理
const getBaseUrl = () => {
	// #ifdef H5
	if (process.env.NODE_ENV === 'development') {
		return 'http://localhost:8080'
	}
	// 生产环境使用相对路径，nginx会代理到后端
	return ''
	// #endif
	
	// #ifndef H5
	// 小程序等其他平台使用公网地址
	return 'http://your-server-ip'
	// #endif
}

const BASE_URL = getBaseUrl()

export const request = (url, options = {}) => {
	return new Promise((resolve, reject) => {
		uni.request({
			url: BASE_URL + url,
			method: options.method || 'GET',
			data: options.data || {},
			header: {
				'Content-Type': 'application/json',
				...options.header
			},
			success: (res) => {
				if (res.statusCode === 200) {
					resolve(res.data)
				} else {
					reject(new Error(`请求失败: ${res.statusCode} - ${res.data?.message || res.errMsg || '未知错误'}`))
				}
			},
			fail: (err) => {
				console.error('请求失败:', err)
				reject(new Error(err.errMsg || '网络请求失败，请检查网络连接和后端服务'))
			}
		})
	})
}

