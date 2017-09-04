<!DOCTYPE html>
<html>
<head>
    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes" />
    <title>系统简介</title>
    <link rel="stylesheet" type="text/css" href="../../css/navstyle.css">
    <link rel="stylesheet" type="text/css" href="../../css/nav.css">
    <link rel="icon" type="image/x-icon" href="../../img/favicon.ico">

</head>
<body>

<div id="nav">APP上传下载管理系统</div>
<div id="title1">应用发布，仅需两步</div>
<div id="msg1">
    将应用上传到网站，自动生成下载地址和二维码
</div>
<div id="msg2">
    扫一扫二维码，或直接打开下载地址，即可安装
</div>

<div id="title2">
    主要功能
    <ul>
        <li>支持安卓和iOS企业应用分发功能</li>
        <li>上传发布，自动生成二维及下载地址</li>
        <li>适合市场推广，迅速抢占用户市场</li>
        <li>支持window,linux,ubuntu等主流服务器</li>
        <li>中小型企业自主管理企业应用及应用内侧</li>
        <li>解除对fir.im和蒲公英的依赖，高效稳定</li>
        <li>价格优惠，欢迎咨询QQ:<a id="qqcontent" href="tencent://message/?Menu=yes&uin=282834524" target="_blank" >1542997454</a></li>
    </ul>
</div>

<div id="btns">
    <a href="javascript:void(0);" onclick="turnPage()">立即登录</a>
</div>

<script>
    function turnPage() {
        window.webkit.messageHandlers.gotoLogin.postMessage({"sex":"men","name":"wangshengyuan"});
    }
</script>

</body>
</html>