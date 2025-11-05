<template>
	<view class="container">
		<view class="welcome">
			<text class="title">欢迎使用</text>
			<text class="subtitle">用户使用频率统计系统</text>
		</view>
		<view class="button-group">
			<button class="btn" @click="goToChart">查看图表</button>
		</view>
	</view>
</template>

<script setup>
const goToChart = () => {
	uni.navigateTo({
		url: '/pages/chart/chart'
	})
}
</script>

<style scoped>
.container {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	min-height: 100vh;
	background-color: #f8f8f8;
	padding: 40rpx;
}

.welcome {
	text-align: center;
	margin-bottom: 80rpx;
}

.title {
	display: block;
	font-size: 48rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 20rpx;
}

.subtitle {
	display: block;
	font-size: 28rpx;
	color: #666;
}

.button-group {
	width: 100%;
}

.btn {
	width: 100%;
	height: 88rpx;
	line-height: 88rpx;
	background-color: #007AFF;
	color: #fff;
	border-radius: 10rpx;
	font-size: 32rpx;
	border: none;
}
</style>

