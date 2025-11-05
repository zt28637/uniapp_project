<template>
	<view class="container">
		<view class="header">
			<text class="title">用户使用频率统计</text>
			<text class="subtitle">{{ subtitle }}</text>
		</view>
		<view class="chart-container">
			<view v-if="loading" class="loading">加载中...</view>
			<view v-else-if="error" class="error">{{ error }}</view>
			<view v-else class="chart-wrapper">
				<view id="chart" class="chart"></view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted, nextTick, onUnmounted } from 'vue'
import { request } from '../../utils/request'

const loading = ref(true)
const error = ref('')
const chartData = ref(null)
const subtitle = ref('用户使用统计')
let chartInstance = null

const getUserFrequency = async () => {
	try {
		loading.value = true
		error.value = ''
		const res = await request('/api/dashboard/getUserFrequency')
		if (res.code === 200) {
			chartData.value = res.data
			console.log('图表数据:', chartData.value)
			
			if (!chartData.value || !chartData.value.categories || chartData.value.categories.length === 0) {
				error.value = '数据为空，请检查后端数据'
				subtitle.value = '暂无数据'
				return
			}
			
			// 根据实际数据点数量动态更新副标题
			const dataCount = chartData.value.categories ? chartData.value.categories.length : 0
			if (dataCount > 0) {
				subtitle.value = `显示${dataCount}个数据点`
			} else {
				subtitle.value = '用户使用统计'
			}
			
			await nextTick()
			setTimeout(() => {
				initChart()
			}, 100)
		} else {
			error.value = res.message || '获取数据失败'
		}
	} catch (e) {
		error.value = '网络请求失败: ' + (e.message || '请检查后端服务是否启动')
		console.error('请求错误:', e)
	} finally {
		loading.value = false
	}
}

const initChart = () => {
	// #ifdef H5
	// H5环境使用CDN引入的ECharts
	if (typeof echarts === 'undefined') {
		console.error('ECharts未加载，请检查CDN')
		error.value = '图表库加载失败'
		return
	}
	
	const chartDom = document.getElementById('chart')
	if (!chartDom) {
		console.error('找不到图表容器')
		setTimeout(() => {
			initChart()
		}, 200)
		return
	}
	
	chartInstance = echarts.init(chartDom)
	updateChart()
	
	// 响应式调整
	const resizeHandler = () => {
		chartInstance?.resize()
	}
	window.addEventListener('resize', resizeHandler)
	
	// 保存resize handler以便清理
	chartInstance._resizeHandler = resizeHandler
	// #endif
	
	// #ifndef H5
	// 小程序和其他平台提示
	error.value = '当前环境不支持图表显示，请在H5环境下查看'
	// #endif
}

const updateChart = () => {
	if (!chartData.value || !chartInstance) return
	
	const categories = chartData.value.categories || []
	const values = chartData.value.values || []
	
	const option = {
		tooltip: {
			trigger: 'axis',
			axisPointer: {
				type: 'line'
			}
		},
		grid: {
			left: '10%',
			right: '5%',
			bottom: '15%',
			top: '5%',
			height: 'auto'
		},
		xAxis: {
			type: 'category',
			data: categories,
			axisLabel: {
				rotate: 0,
				fontSize: 11
			},
			name: '日期',
			nameLocation: 'middle',
			nameGap: 30
		},
		yAxis: {
			type: 'value',
			name: '使用次数',
			nameLocation: 'middle',
			nameGap: 50,
			axisLabel: {
				fontSize: 11,
				showMinLabel: true,
				showMaxLabel: true
			},
			minInterval: 1,
			splitNumber: 5,
			splitLine: {
				show: true,
				lineStyle: {
					color: '#e5e5e5',
					type: 'dashed'
				},
				interval: 0
			}
		},
		series: [
			{
				name: '使用次数',
				type: 'line',
				smooth: true,
				data: values,
				itemStyle: {
					color: '#007AFF'
				},
				areaStyle: {
					color: {
						type: 'linear',
						x: 0,
						y: 0,
						x2: 0,
						y2: 1,
						colorStops: [
							{ offset: 0, color: 'rgba(0, 122, 255, 0.3)' },
							{ offset: 1, color: 'rgba(0, 122, 255, 0.05)' }
						]
					}
				},
				lineStyle: {
					width: 3
				},
				symbol: 'circle',
				symbolSize: 8,
				label: {
					show: true,
					position: 'top',
					fontSize: 10
				}
			}
		]
	}
	
	chartInstance.setOption(option)
}

onMounted(() => {
	getUserFrequency()
})

onUnmounted(() => {
	if (chartInstance) {
		// #ifdef H5
		if (chartInstance._resizeHandler) {
			window.removeEventListener('resize', chartInstance._resizeHandler)
		}
		// #endif
		chartInstance.dispose()
		chartInstance = null
	}
})
</script>

<style scoped>
.container {
	padding: 20rpx;
	background-color: #f8f8f8;
	min-height: 100vh;
}

.header {
	text-align: center;
	margin-bottom: 30rpx;
}

.title {
	font-size: 36rpx;
	font-weight: bold;
	color: #333;
	display: block;
	margin-bottom: 10rpx;
}

.subtitle {
	font-size: 24rpx;
	color: #999;
	display: block;
}

.chart-container {
	background-color: #fff;
	border-radius: 10rpx;
	padding: 30rpx;
	box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.1);
}

.loading, .error {
	text-align: center;
	padding: 100rpx 0;
	color: #999;
	font-size: 28rpx;
}

.error {
	color: #ff3b30;
}

.chart-wrapper {
	width: 100%;
	height: 350px;
}

.chart {
	width: 100%;
	height: 100%;
}
</style>
