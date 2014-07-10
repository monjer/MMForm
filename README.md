MMForm
======

Flex中模拟表单提交，实现一次请求中的多文件上传功能

示例
====

	var form:MMForm = new MMForm();
	
1. 添加 _普通表单域_

		var formField : MMFormField = new MMFormField({
			name:'uname',
			value:'manjun.han'
		});

		form.addFormField(formField);
	
2. 添加 _文件/二进制类型表单域_，通常使用`FileReference`获取用户选择的文件进行上传，一次提交中可以添加多个 _文件/二进制类型表单域_

		var fileRef:FileReference ＝ new FileReference() ;
		fileRef.browser();
		fileRef.load();
		
		// fileRef complete handler中添加文件数据	
		var formField : MMMultipartFormField = new MMMultipartFormField({
				fieldName:"uploadFieldname" ,	
				fileName:"uploadFileName",		
				fileData:fileRef.data,	
				fileContentType:'image/png'
		});

3. 添加事件监听

		var oberserver:MyObserver = new MyObserver() ;
		
		form.setObserverAndHandlers(this , {
			completeHandler:oberserver.completeHandler,
			openHandler:oberserver.openHandler,
			progressHandler:oberserver.progressHandler,
			securityErrorHandler:oberserver.securityErrorHandler,
			httpStatusHandler:oberserver.httpStatusHandler,
			ioErrorHandler:oberserver.ioErrorHandler
		});
		
		// MyObserver handlers
		
		private function openHandler(event:Event):void 
		{
			trace("openHandler: " + event);
		}
		
		private function completeHandler(event:Event , httpResponseData:Object):void 
		{		
			trace("completeHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			trace("progressHandler: " + event);
		}
				
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void 
		{			
			trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
		}
	
4. 提交	

		var action : String = "http://form.post.action" ;		
		form.submit(action);