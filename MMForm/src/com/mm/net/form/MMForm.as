package com.mm.net.form
{
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;


	/**
	 * 
	 * Flex 模拟表单上传文件类型数据
	 * 
	 * @author manjun.han
	 * @date 2014.7.10
	 * 
	 * 参考:http://www.w3.org/TR/html401/interact/forms.html
	 */
	public final class MMForm
	{		
		//------------------------------------------
		// constructor
		//------------------------------------------
		
		public function MMForm(){}
		
		//------------------------------------------
		// 属性
		//------------------------------------------
		
		public static var sharedInstance:MMForm = new MMForm();// 单例对象
		
		private var formUploader:URLLoader;
		
		private var urlRequest:URLRequest ;
		
		private var formFields:Array = [];
		
		private var boundary:String = "MMFormBoundaryP6fk9Xsc4BGl3Kll" ; // 边界字符串
			
		private var CRLF:String = "\r\n" ; // 回车换行符
		
		private var formData:ByteArray = new ByteArray();
		
		private var observer:Object ;
		
		private var observerHandlers:Object ;
		
		//------------------------------------------
		// Form方法
		//------------------------------------------
		
		/**
		 * 初始化表单对象，添加表单的contentType，指定发送的方法，
		 */
		private function initializeUploader():void
		{			
			this.formUploader = new URLLoader();
			
			this.appendEventListener() ;
			
			this.urlRequest = new URLRequest() ;
			
			var contentType:String = "multipart/form-data; boundary="+this.boundary ;
			
			this.urlRequest.method = URLRequestMethod.POST ;
			
			// 不允许直接设置
			//this.urlRequest.contentType = "multipart/form-data; boundary="+ FileUtil.getBoundary();
			
			this.urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type",contentType));
			
			this.formUploader.dataFormat = URLLoaderDataFormat.TEXT;
			
		}		
		
		/**
		 * 为URLLoader添加事件
		 */
		private function appendEventListener():void
		{
			this.formUploader.addEventListener(Event.COMPLETE, completeHandler);
			
			this.formUploader.addEventListener(Event.OPEN, openHandler);
			
			this.formUploader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			this.formUploader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			this.formUploader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			
			this.formUploader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		/**
		 * 提交表单数据
		 * @param actionURL 指定server端接受数据的action名称
		 */
		public function submit(actionURL:String):void
		{
			this.initializeUploader();
			
			this.urlRequest.url = actionURL ;
						
			this.urlRequest.data = this.generateFormData() ;

			this.formUploader.load(this.urlRequest);

		}
		
		/**
		 * 向表单中添加表单域
		 * @param {MMFormField|MMFileFormField}
		 */
		public function addFormField(field:Object):void
		{
			if(!this.formFields){
				this.formFields = new Array();
			}
			this.formFields.push(field);
		}
		
		/**
		 * 组合所有表单项数据，生成要在HTTP协议中发送的二进制流
		 * @return 发送的二进制流
		 */
		private function generateFormData():ByteArray
		{
			if(!this.formData){
				this.formData = new ByteArray();
			}
			var length:Number = this.formFields.length ;
			
			var field:Object ;
			
			for(var i:Number = 0 ; i < length ; i++){
				
				field = this.formFields[i];
				
				this.appendBoundary();
				
				if(field is MMFormField){
					
					this.appendField(field.name , field.value);
					
				}else if(field is MMMultipartFormField){
					
					this.appendMutiformDataField(field.fieldName,field.fileName,field.fileData,field.fileContentType);		
				}	
			}
			
			this.appendCloseBoundary();
			
			return this.formData ;
		}
		
		/**
		 * 添加line break字符
		 */
		private function appenLinkBreak():void
		{
			this.formData.writeUTF("\r\n");
		}
		
		/**
		 * 添加表单项在http协议间的分隔符
		 */
		private function appendBoundary():void
		{			
			// form body起始边界尾部只能添加一个\r\n
			this.formData.writeUTFBytes("\r\n--MMFormBoundaryP6fk9Xsc4BGl3Kll\r\n") ;
		}
		
		/**
		 * 添加表单项
		 */
		private function appendCloseBoundary():void
		{
			this.formData.writeUTFBytes("\r\n\--MMFormBoundaryP6fk9Xsc4BGl3Kll--\r\n") ;
		}
		
		/**
		 * 添加普通类型的表单项
		 * @prama name 表单项名称
		 * @prama value 表单项名称对应的值
		 */
		private function appendField(name:String , value:String):void
		{
			var fieldString:String = "" ;
			
			fieldString = "Content-Disposition: form-data; name=\""+name+"\"\r\n\r\n" ;
			
			fieldString += value;
					
			this.formData.writeUTFBytes(fieldString);
		}
		
		/**
		 * 添加二进制表单项
		 * @param fieldName 表单项名称
		 * @param fileName 文件名称
		 * @param fileData 文件的二进制数据
		 * @param contentType 文件类型 
		 */
		public function appendMutiformDataField(fieldName:String , fileName:String , fileData:ByteArray , contentType:String):void
		{
			var fieldString:String = "" ;
			
			fieldString += "Content-Disposition: form-data; name=\""+ fieldName +"\"; filename=\""+fileName+"\"\r\n" ;
			
			fieldString += "Content-Type: "+contentType +"\r\n\r\n";
			
			this.formData.writeUTFBytes(fieldString);
			
			this.formData.writeBytes(fileData , 0 , fileData.length);
		}
		
		/**
		 * 添加上传相关事件的监听对象和监听器
		 * @param observer 监听对象
		 * @param observerHandlers 监听器
		 */
		public function setObserverAndHandlers(observer:Object , observerHandlers:Object ):void
		{
			this.observer = observer ;
			
			this.observerHandlers = observerHandlers ;
		}
		
		/**
		 * 清空表单,保证表单数据提交完毕后，释放大数据对象引用 
		 */
		private function clearForm():void
		{
			this.formData = null ;
			this.formFields = null ;
			this.formUploader = null ;
			this.urlRequest = null ;
		}
		
		/**
		 * 删除observer和监听器
		 * @date 2013.9.6
		 */
		public function removeObserver():void
		{
			this.observer = null ;
			this.observerHandlers = null ;		
		}
		
		//------------------------------------------
		// URLLoader Event Handlers
		//------------------------------------------
		
		private function openHandler(event:Event):void
		{
			if(this.observer && this.observerHandlers.openHandler is Function){
				this.observerHandlers.openHandler.call(this.observer , event)
			}
		}
		
		private function completeHandler(event:Event):void
		{
			if(this.observer && this.observerHandlers.completeHandler is Function){
				
				var httpResponseData:Object =  {} ;
				
				if(this.formUploader && this.formUploader.data){
					httpResponseData = JSON.parse(String(this.formUploader.data));
				}
				
				this.clearForm() ; // 循环调用，需保证clearForm在前，否则会将下次的form清掉
				
				this.observerHandlers.completeHandler.call(this.observer , event , httpResponseData);
								
			}	else{
				this.clearForm() ;
			}		
			
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			if(this.observer && this.observerHandlers.progressHandler is Function){
				this.observerHandlers.progressHandler.call(this.observer , event);				
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			if(this.observer && this.observerHandlers.securityErrorHandler is Function){
				this.observerHandlers.securityErrorHandler.call(this.observer , event)
			}
			this.clearForm() ;
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			if(this.observer && this.observerHandlers.httpStatusHandler is Function){
				this.observerHandlers.httpStatusHandler.call(this.observer , event)
			}			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if(this.observer && this.observerHandlers.ioErrorHandler is Function){
				this.observerHandlers.ioErrorHandler.call(this.observer , event)
			}
			this.clearForm() ;
		}
		
	}
}