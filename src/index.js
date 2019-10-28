/* globals alert */
const pluginQrcodeScanner = {
  show () {
    alert('Module pluginQrcodeScanner is created sucessfully ');
  }
};

const meta = {
  pluginQrcodeScanner: [{
    lowerCamelCaseName: 'show',
    args: []
  }]
};

function init (weex) {
  weex.registerModule('pluginQrcodeScanner', pluginQrcodeScanner, meta);
}

export default {
  init: init
};
