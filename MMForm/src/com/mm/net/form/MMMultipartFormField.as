package com.mm.net.form
{
	import flash.utils.ByteArray;

	/**
	 *  
	 * 文件类型表单域对象
	 * 
	 * @author manjun.han
	 * @date 2014.7.10
	 */
	public class MMMultipartFormField
	{
		public function MMMultipartFormField(options:Object=null)
		{
			options = options || {
				fieldName:"uploadFile",
				fileName:"file",
				fileContentType:"text/plain",
				fileData:new ByteArray()
			};
			
			this.fieldName = options.fieldName ;
			
			this.fileName = options.fileName ;
			
			this.fileContentType = options.fileContentType ;
			
			this.fileData = options.fileData ;
		}
		
		public var fieldName:String = "" ;
		
		public var fileName:String = "" ;
		
		public var fileContentType:String = "text/plain" ;
		
		public var fileData:ByteArray = new ByteArray() ;
		
		public var formItemType:String = "FormFileItem" ;
	}
}