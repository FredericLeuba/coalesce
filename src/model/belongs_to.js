import Relationship from './relationship';
import isEqual from '../utils/is_equal';

export default class BelongsTo extends Relationship {
  
  defineProperty(prototype) {
    var name = this.name,
        embedded = this.embedded;
    Object.defineProperty(prototype, name, {
      enumerable: true,
      configurable: true,
      get: function() {
        var value = this._relationships[name],
            session = this.session;
        if(session && value && value.session !== session) {
          value = this._relationships[name] = this.session.add(value);
        }
        return value;
      },
      set: function(value) {
        var oldValue = this._relationships[name];
        if(oldValue === value) return;
        this.belongsToWillChange(name);
        var session = this.session;
        if(session) {
          session.modelWillBecomeDirty(this);
          if(value) {
            value = session.add(value);
          }
        }
        if(value && embedded) {
          value._parent = this;
        }
        this._relationships[name] = value;
        this.belongsToDidChange(name);
        return value;
      }
    });
  }
  
}
