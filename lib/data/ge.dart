class Strs{
  //url
  static const String baseUrl = 'https://neko.lacus.site';
  static const String apiVersion = '1';
  static const String baseApiUrl = baseUrl + '/v' + apiVersion;
  static const String baseUserApiUrl = baseApiUrl + '/user';
  static const String baseAdminApiUrl = baseApiUrl + '/admin';

  static const String userLogin = baseUserApiUrl + '/login';
  static const String userChangeNick = baseUserApiUrl + '/nick';
  static const String userClearNotification = baseUserApiUrl + '/clear';
  static const String userGetAllCats = baseUserApiUrl + '/neko';
  static const String userGetCatDetail = baseUserApiUrl + '/detail';
  static const String userComment = baseUserApiUrl + '/comment';
  static const String userGetVersion = baseUserApiUrl + '/version';

  static const String adminUpload = baseAdminApiUrl + '/upload';
  static const String adminManageComment = baseAdminApiUrl + '/comment';
  static const String adminManageCat = baseAdminApiUrl + '/neko';
  static const String adminManageVersion = baseAdminApiUrl + '/version';

  //json
  static const String keyComment = 'comment';
  static const String keyCatInfo = 'neko_info';
  static const String keyCatId = 'nekoid';
  static const String keyCatName = 'name';
  static const String keyCatArea = 'zone';
  static const String keyCatSex = 'sex';
  static const String keyCatDescription = 'description';
  static const String keyCatCourage = 'coward';
  static const String keyCatAppearRate = 'haunt';
  static const String keyCatAvatar = 'avatar';
  static const String keyCatImg = 'img';
  static const String keyCatPosition = 'position';
  static const String keyUserInfo = 'user_info';
  static const String keyUserAccount = 'cid';
  static const String keyUserPwd = 'pwd';
  static const String keyUserId = 'openid';
  static const String keyUserName = 'nick';
  static const String keyUserImg = 'avatar';
  static const String keyCommentID = 'comment_id';
  static const String keyCommentContent = 'content';
  static const String keyReply = 'reply';
  static const String keyReplyId = 'reply_id';
  static const String keyReplyCreateTime = 'create_time';

  //app
  static const String appName = 'Toast Neko';
  static const String noMore = '没有了\n(´･ω･`)';
  static const String catPosition = '发现地';
  static const String about = '关于';
  static const String feedback = '向我们反馈';
  static const String joinUserGroup = '加入用户群';
  static const String usageHelp = '使用帮助';
  static const String sendEmail = '请发送邮件至\n2036293523@qq.com';
  static const String joinQQUrl = 'https://jq.qq.com/?_wv=1027&k=86nHLzAl';
  static const String photoWrongSolution = '如果图片显示错误，请清除所有数据。';
  static const String helpText1 = '首页上下滑动，点击查看图片。';

  //asset
  static const String custMapW = 'assets/map/CustW.png';
  static const String custMapE = 'assets/map/CustE.png';
  static const String custMapS = 'assets/map/CustS.png';
  static const String custMapDarkW = 'assets/map/Dark-CustW.png';
  static const String custMapDarkE = 'assets/map/Dark-CustE.png';
  static const String custMapDarkS = 'assets/map/Dark-CustS.png';
  static const String bannerToastNeko = 'assets/toast_neko.png';

  //error
  static const String noRequestData = 'no request data';
}