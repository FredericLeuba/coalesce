import RestAdapter from 'coalesce/rest/rest_adapter';
import Coalesce from 'coalesce';

export default class TestRestAdapter extends RestAdapter {
  constructor() {
    super();
    this.h = [];
    this.r = {};
  }

  ajax(url, type, hash) {
    var adapter = this;
    return new Coalesce.Promise(function(resolve, reject) {
      var key = type + ":" + url;
      adapter.h.push(key);
      var json = adapter.r[key];
      if(hash && typeof hash.data === 'string') {
        hash.data = JSON.parse(hash.data);
      }
      if(!json) {
        throw "No data for #{key}";
      }
      if(typeof json === 'function') {
        json = json(url, type, hash);
      }
      adapter.runLater(function() { resolve(json) }, 0);
    });
  }

  runLater(callback) {
    Coalesce.run.later(callback, 0);
  }

}
