import os 
//Hodaya Rozental 315476523
//Shira Orbach 315234484

__global (
	arr_keyword    = ['class','constructor','function','method','field','static','var','int','char','boolean','void','true','false','null',
	'this','let','do','if','else','while','return']
	arr_symbol    = ['{','}','(',')','[',']','.',',',';','+','-','*','/','&','|','>','<','=','~']
)

/*
The func translate the token to xml format and returns it as string
*/
fn token_print(tokenClassification string, token string)(string) {
	mut str:='<'+tokenClassification+'> '
	str+=token+r' </'+tokenClassification+'>\n'  
	return str
}

fn main() {
	mut path:=os.input("Enter the path")
	files:= os.ls(path) or { println(err)return}
	folder:=path.split(r'\')
	folder_name:=folder#[-1..]  //the last item in the array
	mut str:='' //reset the string of the code
	filtered:=files.filter(it#[-5..]=='.jack')
	for file in filtered //for each file
	{
		name:=file#[..-5] //the file name without '.jack'
		mut newfile := os.create(path+r'\'+name+'T1'+'.xml') or{println(err)return} //create xml file
		newfile.write_string('<tokens>'+'\n') or { println ( err ) return }
		// flag: 0= false, 1= /* or /**, 2= " 
		mut flag:=0 //if found "/*" -> the flag of documentation will be true until "*/"
		mut current_token:=""
		text := os.read_lines(path+r"\"+file) or {println(err)return}
		mut i:=0 // loops counter
		mut ch:=''   //the current char
		mut word:="" //the current word/string/number
		mut word_flag:=false //if we are in the middle of keyword/identifier
		mut num_flag:=false  //if we are in the middle of number
		for line in text //for each line in file
		{
			i=0
			for //every char in line 
			{
				if i>=line.len
				{
					break
				}
				ch=line[i].ascii_str() //the current char
				match flag{ // check if documentation
					0 {
						if (ch>='a' && ch<='z') || (ch>='A' && ch<='Z')
						{
							word_flag=true
						}
						
						if word_flag  //if its a keyword or identifier
						{
							if (ch>='a' && ch<='z') || (ch>='A' && ch<='Z') || (ch>='0' && ch<='9') ||ch=='_'  
							{
								word+=ch
							}
							else{ // the word was finished
								if word in arr_keyword
								{
									str+=token_print('keyword',word)
								}else
								{
									str+=token_print('identifier',word)
								}
								word_flag=false
								word=''
							}
						}
						else{
							if (ch>='0') && (ch<='9')
							{
								num_flag=true
							}	
						}
						if num_flag  //if its a number
						{
							if (ch>='0') && (ch<='9')
							{
								word+=ch
							}
							else{ // the number was finished
								str+=token_print('integerConstant',word)
								num_flag=false
								word=""
							}
						}
						if (ch in arr_symbol) || (ch=='"')
						{
							match ch{
							  '/'{
								if line[i+1].ascii_str()=='*'      // if "/*"
								{
									flag=1
									i++
									if line[i+1].ascii_str()=='*' // if "/**"
									{
										i++
									}
								}
								else {
									if line[i+1].ascii_str()=='/'  // if "//"
									{
										i+=line.len // drop line
									}
									else{
										str+=token_print('symbol',r'/')
									}
								}
							  }
							  '<'{str+=token_print('symbol','&lt;')}
							  '>'{str+=token_print('symbol','&gt;')}
							  "&"{str+=token_print('symbol','&amp;')}
							    '"'{
								flag=2
								//str+=token_print('symbol','&quet;')
							  }
							   else{str+=token_print('symbol',ch)}
							}
						}
						//space will not change	
					}
					1 {  
						if ch=='*'
						{
							if line[i+1].ascii_str()==r'/'
							{
								flag=0
								i++
							}
						}
					}
					2{
						if ch!='"'
						{
							word+=ch
						}
						else{
							str+=token_print("stringConstant",word)
							flag=0
							word=''
						}
					}
					else{}

				}
				
				i++
			}
			newfile.write_string(str) or { println ( err ) return }
			str=''
		}
		newfile.write_string('</tokens>') or { println ( err ) return }
	}
}
