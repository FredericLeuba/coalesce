import Model from 'coalesce/model/model';
// Common model setups for tests

function postWithComments() {
  this.App = {};
  class Post extends Coalesce.Model {}
  Post.defineSchema({
    typeKey: 'post',
    attributes: {
      title: {type: 'string'}
    },
    relationships: {
      comments: {kind: 'hasMany', type: 'comment'}
    }
  });
  this.App.Post = this.Post = Post;
  this.container.register('model:post', Post);

  class Comment extends Coalesce.Model {}
  Comment.defineSchema({
    typeKey: 'comment',
    attributes: {
      body: {type: 'string'}
    },
    relationships: {
      post: {kind: 'belongsTo', type: 'post'}
    }
  });
  this.App.Comment = this.Comment = Comment;
  this.container.register('model:comment', Comment);
}

function postWithEmbeddedComments() {
  postWithComments.apply(this);
  this.Post.defineSchema({
    relationships: {
      comments: {kind: 'hasMany', type: 'comment', embedded: 'always'}
    }
  });
}

function userWithPost() {
  this.App = {};
  class Post extends Model {}
  Post.defineSchema({
    typeKey: 'post',
    attributes: {
      title: {
        type: 'string'
      }
    },
    relationships: {
      user: {
        kind: 'belongsTo',
        type: 'user'
      }
    }
  });

  this.App.Post = this.Post = Post;

  class User extends Model {};
  User.defineSchema({
    typeKey: 'user',
    attributes: {
      name: {
        type: 'string'
      }
    },
    relationships: {
      post: {
        kind: 'belongsTo',
        type: 'post'
      }
    }
  });

  this.App.User = this.User = User;

  this.container.register('model:post', this.Post);
  this.container.register('model:user', this.User);
}

function groupWithMembersWithUsers() {
  class Group extends Model {};
  Group.defineSchema({
    typeKey: 'group',
    attributes: {
      name: {
        type: 'string'
      }
    },
    relationships: {
      members: {
        kind: 'hasMany',
        type: 'member'
      },
      user: {
        kind: 'belongsTo',
        type: 'user'
      }
    }
  });

  this.App.Group = this.Group = Group;

  class Member extends Model {};
  Member.defineSchema({
    typeKey: 'member',
    attributes: {
      role: {
        type: 'string'
      }
    },
    relationships: {
      user: {
        kind: 'belongsTo',
        type: 'user'
      },
      group: {
        kind: 'belongsTo',
        type: 'group'
      }
    }
  });

  this.App.Member = this.Member = Member;

  class User extends Model {};
  User.defineSchema({
    typeKey: 'user',
    attributes: {
      name: {
        type: 'string'
      }
    },
    relationships: {
      groups: {
        kind: 'hasMany',
        type: 'group'
      },
      members: {
        kind: 'hasMany',
        type: 'member'
      }
    }
  });

  this.App.User = this.User = User;

  this.container.register('model:group', this.Group);
  this.container.register('model:member', this.Member);
  this.container.register('model:user', this.User);
}

export {postWithComments, postWithEmbeddedComments, userWithPost, groupWithMembersWithUsers};
