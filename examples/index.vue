<template>
	<div class="wrapper">
    <image :src="logo" class="logo" />
    <text class="greeting">The plugin develop environment is ready!</text>
    <div style="display: flex; flex-direction: row;">
		<div @click="showDialog" class="button">
			<text style="color:#fff">Show Dialog</text>
		</div>
		<div @click="scanQR" class="button">
			<text style="color:#fff">scanQR</text>
		</div>
	</div>
    <text class="message">{{response}}</text>
  </div>
</template>

<script>

	const pluginQrcodeScanner = weex.requireModule('pluginQrcodeScanner');
	module.exports = {
		data: {
			logo: 'http://img1.vued.vanthink.cn/vued08aa73a9ab65dcbd360ec54659ada97c.png',
			response: {}
		},
		methods: {
			showDialog: function() {
				console.log('-> showDialog')
				pluginQrcodeScanner.show(JSON.stringify({title: 'QR Code Scanner', message: weex.config.env.osName+' Module pluginQrcodeScanner was created sucessfully'}));
			},
			scanQR: function() {
				console.log('-> scanQR')
				pluginQrcodeScanner.scanQR((data) => {
					this.response = data
				})
			}
		}
	}
</script>


<style>
	.wrapper {
		justify-content: center;
		align-items: center;
	}
	.logo {
		width: 424px;
		height: 200px;
	}
	.greeting {
		text-align: center;
		margin-top: 20px;
		line-height: 80px;
		font-size: 36px;
		color: #41B883;
	}
	.message {
		font-size: 26px;
		color: #727272;
	}
	.button {
		margin: 20px;
		padding:20px;
		background-color:#1ba1e2;
		color:#fff;
	}
</style>