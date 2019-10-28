import Vue from 'vue';

import weex from 'weex-vue-render';

import PluginQrcodeScanner from '../src/index';

weex.init(Vue);

weex.install(PluginQrcodeScanner)

const App = require('./index.vue');
App.el = '#root';
new Vue(App);
