package com.mm.net.form
{
	/**
	 * 
	 * 普通表单域对象，键值对(k/v)
	 * 
	 * @author manjun.han
	 * @date 2014.7.10
	 */
	public class MMFormField
	{
		public function MMFormField(options:Object=null){
			
			options = options || {
				name:"",
				value:""
			}
			
			this.name = options.name ;
			
			this.value = options.value ;
		}
		
		public var name:String = "" ;
		
		public var value:String = "" ;
		
		public var formItemType:String = "FormItem" ;
	}
}