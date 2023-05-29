import os 
//Hodaya Rozental 315476523
//Shira Orbach 315234484

__global (
	countlabels    = int(0)
)

/*
The func translate the Add command from vm to asm and return it as a string
*/
fn add()(string)
{
	mut result:='//add'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='D=M'+'\n' //save the first argument 
	result+='A=A-1'+'\n'
	result+='M=M+D'+'\n' //adding
	result+='@0'+'\n'
	result+='M=M-1'+'\n' //RAM[0]=RAM[0]-1 -> we took 2 arguments and returned one result
	return result
}

/*
The func translate the Negative command from vm to asm and return it as a string
*/
fn neg()(string)
{
	mut result:='//neg'+'\n'
	result+='@0'+'\n'  
	result+='A=M-1'+'\n' //RAM[0]-1=256
	result+='M=-M'+'\n' //RAM[256]=-RAM[256]
	return result
}

/*
The func translate the Sub command from vm to asm and return it as a string
*/
fn sub()(string)
{
	mut result:='//sub'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n' //RAM[0]-1
	result+='D=M'+'\n' // first value
	result+='A=A-1'+'\n'
	result+='M=M-D'+'\n'
	result+='@0'+'\n'
	result+='M=M-1'+'\n'  //RAM[0]=RAM[0]-1
	return result
}

/*
The func translate the Greater than command from vm to asm and return it as a string
*/
fn gt()(string)
{
	mut result:='//gt'+'\n'
	result+='@0'+'\n'
	result+='M=M-1'+'\n'
	result+='A=M'+'\n' 
	result+='D=M'+'\n' // first value
	result+='A=A-1'+'\n' 
	result+='D=M-D'+'\n' 
	result+='@IF_GT_TRUE'+countlabels.str()+'\n' 
	result+='D;JGT'+'\n' 
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='M=0'+'\n'
	result+='@IF_GT_FALSE'+countlabels.str()+'\n'
	result+='0;JMP'+'\n'
	result+='(IF_GT_TRUE'+countlabels.str()+')'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='M=-1'+'\n'
	result+='(IF_GT_FALSE'+countlabels.str()+')'+'\n'
	countlabels++
	return result
}

/*
The func translate the Less than command from vm to asm and return it as a string
*/
fn lt()(string)
{
	mut result:='//lt'+'\n'
	result+='@0'+'\n'
	result+='M=M-1'+'\n'
	result+='A=M'+'\n' 
	result+='D=M'+'\n' // first value
	result+='A=A-1'+'\n' 
	result+='D=M-D'+'\n' 
	result+='@IF_LT_TRUE'+countlabels.str()+'\n' 
	result+='D;JLT'+'\n' 
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='M=0'+'\n'
	result+='@IF_LT_FALSE'+countlabels.str()+'\n'
	result+='0;JMP'+'\n'
	result+='(IF_LT_TRUE'+countlabels.str()+')'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='M=-1'+'\n'
	result+='(IF_LT_FALSE'+countlabels.str()+')'+'\n'
	countlabels++
	return result
}

/*
The func translate the Equal command from vm to asm and return it as a string
*/
fn eq()(string)
{
	mut result:='//eq'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='D=M'+'\n' //save the first argument 
	result+='A=A-1'+'\n'
	result+='D=D-M'+'\n' //compute
	result+='@IF_EQ_TRUE'+countlabels.str()+'\n' 
	result+='D;JEQ'+'\n' //if equal- D'll be 0 and we'll jump
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='A=A-1'+'\n'
	result+='M=0'+'\n' //push 0 as "false"
	result+='@IF_EQ_FALSE'+countlabels.str()+'\n'
	result+='0;JMP'+'\n'
	
	result+='(IF_EQ_TRUE'+countlabels.str()+')'+'\n' //the true label
	result+='D=-1'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='A=A-1'+'\n'
	result+='M=D'+'\n' //push -1 as "true"
	result+='(IF_EQ_FALSE'+countlabels.str()+')'+'\n' //the false label
	result+='@0'+'\n'	
	result+='M=M-1'+'\n' //RAM[0]=RAM[0]-1 -> we took 2 arguments and returned one result
	countlabels++
	return result
}

/*
The func translate the And command from vm to asm and return it as a string
*/
fn and_fn()(string)
{
	mut result:='//and'+'\n'
	result+='@0'+'\n'	
	result+='A=M-1'+'\n'
	result+='D=M'+'\n' //save the first argument 
	result+='A=A-1'+'\n' //the second argument
	result+='M=M&D'+'\n' //AND
	result+='@0'+'\n'
	result+='M=M-1'+'\n' //RAM[0]=RAM[0]-1 -> we took 2 arguments and returned one result
	return result
}

/*
The func translate the Or command from vm to asm and return it as a string
*/
fn or_fn()(string)
{
	mut result:='//or'+'\n'
	result+='@0'+'\n'	
	result+='A=M-1'+'\n'
	result+='D=M'+'\n' //save the first argument 
	result+='A=A-1'+'\n' //the second argument
	result+='M=M|D'+'\n' //OR
	result+='@0'+'\n'
	result+='M=M-1'+'\n' //RAM[0]=RAM[0]-1 -> we took 2 arguments and returned one result
	return result
}

/*
The func translate the Not command from vm to asm and return it as a string
*/
fn not_fn()(string)
{
	mut result:='//not'+'\n'
	result+='@0'+'\n'
	result+='A=M-1'+'\n'
	result+='M=!M'+'\n' 
	return result
}
/*
The func translate the Pop command from vm to asm and return it as a string
*/
fn pop(seg string, x int, file_name string)(string)
{
	    mut result:='//pop '+seg+' '+x.str()+'\n'
		result+='@0'+'\n'
		result+='A=M-1'+'\n' //A=RAM[0]-1=256
		result+='D=M'+'\n'  //D=RAM[256]=the value to pop
		result+=match seg{
			'local'{
				'@LCL'+'\n'
				+'A=M'+'\n'   // A=RAM[LCL]
			}
			'argument'{
				'@ARG'+'\n'
				+'A=M'+'\n'   //A=RAM[ARG]
			}
			'this'{
				'@THIS'+'\n'
				+'A=M'+'\n'   //A=RAM[THIS]
			}
			'that'{
				'@THAT'+'\n'
				+'A=M'+'\n'    //A=RAM[THAT]
			}
			'temp'{
				'@5'+'\n'
			}
			'static'{
				'@'+file_name+'.'+x.str()+'\n'
			}
			'pointer'{
				if x==0 {
					'@THIS'+'\n'
				} 
				else { // if x==1 {
					'@THAT'+'\n'
				}
			}
			else{''}
		}
		if seg!='static' && seg!='pointer' {
			for i in 0..x {
				result+='A=A+1'+'\n'
			}
		}
		result+='M=D'+'\n'    //pop the value to the desired location.
		result+='@0'+'\n'
		result+='M=M-1'+'\n' //Lowers the stack pointer by 1.
		return result

}

/*
The func translate the Push command from vm to asm and return it as a string
*/
fn push(seg string, x string, file_name string)(string)
{
	mut result:='//push '+seg+' '+x+'\n'
	result+='@'+x+'\n'
	result+='D=A'+'\n'
	result+=match seg{
			'local'{
				'@LCL'+'\n'
				+'A=M+D'+'\n'   // A=RAM[LCL]+x
				+'D=M'+'\n'     //D=RAM[ RAM[LCL]+x ]= the value to push
			}
			'argument'{
				'@ARG'+'\n'
				+'A=M+D'+'\n'   //A=RAM[ARG]+x
				+'D=M'+'\n'     //D=RAM[ RAM[ARG]+x ]= the value to push
			}
			'this'{
				'@THIS'+'\n'
				+'A=M+D'+'\n'   //A=RAM[THIS]+x
				+'D=M'+'\n'     //D=RAM[ RAM[THIS]+x ]= the value to push
			}
			'that'{
				'@THAT'+'\n'
				+'A=M+D'+'\n'    //A=RAM[THAT]+x
				+'D=M'+'\n'      //D=RAM[ RAM[THAT]+x ]= the value to push
			}
			'temp'{
				'@5'+'\n'
				+'A=A+D'+'\n' //A=5+x
				+'D=M'+'\n'   //D=RAM[ 5+x ]= the value to push
			}
			'static'{
				'@'+file_name+'.'+x+'\n'
				+'D=M'+'\n'   //D=RAM[ file_name.x ]= the value to push
			}
			'pointer'{
				if x.int()==0 {
					'@THIS'+'\n'
					+'D=M'+'\n'
				} else{ // if x.int()==1 {
					'@THAT'+'\n'
					+'D=M'+'\n'
				}
			}
			//'constant'{} ->we simply push the x to the stack in the next lines.
			else{''}
		}
		result+='@0'+'\n'
		result+='A=M'+'\n' //A=RAM[0]=256
		result+='M=D'+'\n'  //RAM[256]=D ->the push
		result+='@0'+'\n'
		result+='M=M+1'+'\n'  //Promotes the stack pointer by 1
		return result	
}

/*
The func translate the if-goto command from vm to asm and return it as a string
*/
fn if_goto(c string, name string)(string) 
{
	mut result:='//if-goto '+c+'\n'
	result+='@SP'+'\n'
	result+='M=M-1'+'\n' //M=RAM[0]-1=256
	result+='A=M'+'\n'
	result+='D=M'+'\n'  //D=RAM[256]=the value in the top of the stack
	result+='@'+name+'.'+c+'\n' // the address to jump to
	result+='D;JNE'+'\n'  //if D!=0 ->jump
	return result
}

/*
The func translate the memory storage (before func call) from vm to asm and return it as a string
*/
fn memory_storage(seg string)(string)
{
	mut result:='//memory_storage '+seg+'\n'
	result+='@'+seg+'\n'
	result+='D=M'+'\n'
	result+='@SP'+'\n'
	result+='A=M'+'\n'
	result+='M=D'+'\n'
	result+='@SP'+'\n'
	result+='M=M+1'+'\n'
	return result
}

/*
The func translate a func call command from vm to asm and return it as a string
*/
fn call_fn(g string, n string, name string)(string) {
	mut result:='//call '+g+' '+n+'\n'
	
	// push return-address
	result+='@'+g+'.'+'ReturnAddress'+countlabels.str()+'\n'
	result+='D=A'+'\n'
	result+='@SP'+'\n'
	result+='A=M'+'\n'
	result+='M=D'+'\n'
	result+='@SP'+'\n'
	result+='M=M+1'+'\n'
	
	// push LCL, ARG, THIS, THAT
	result+=memory_storage('LCL')
	result+=memory_storage('ARG')
	result+=memory_storage('THIS')
	result+=memory_storage('THAT')
	
	// ARG = SP-n-5 
	result+='@SP'+'\n'
	result+='D=M'+'\n'
	new_arg:=n.int()+5
	result+='@'+new_arg.str()+'\n'  // n+5 
	result+='D=D-A'+'\n'
	result+='@ARG'+'\n'
	result+='M=D'+'\n'
	
	// LCL = SP
	result+='@SP'+'\n'
	result+='D=M'+'\n'
	result+='@LCL'+'\n'
	result+='M=D'+'\n'

	// goto g
	result+='@'+g+'\n'
	result+='0; JMP'+'\n'

	// label return-address
	result+='('+g+'.ReturnAddress'+countlabels.str()+')'+'\n'
	countlabels++
	return result
}

/*
The func translate the memory saving for the local variables
of the function from vm to asm and return it as a string
*/
fn func_fn(g string,k string, name string)(string)
{
	mut result:='//function '+g+' '+k+'\n'
	result+='('+g+')'+'\n' //label g
	//reset the local variables
	for i in 0..k.int() {
		result+=push('constant','0',name)
	}
	return result
}

/*
The func translate the memory restoration (before return command)
from vm to asm and return it as a string
*/
fn memory_restoration(seg string)(string)
{
	mut result:='//memory_restoration '+seg+'\n'
	result+='@LCL'+'\n'
	result+='M=M-1'+'\n'
	result+='A=M'+'\n'
	result+='D=M'+'\n'
	result+='@'+seg+'\n'
	result+='M=D'+'\n'
	return result
}

/*
The func translate a func call command from vm to asm and return it as a string
*/
fn ret()(string) {
	mut result:='//return'+'\n'
	
	result+='@LCL'+'\n'
	result+='D=M'+'\n' //D=LCL
	
	// RET = * (FRAME-5) -> RAM[13] = (LOCAL - 5)
	result+='@5'+'\n'
	result+='A=D-A'+'\n'
	result+='D=M'+'\n'
	result+='@13'+'\n'
	result+='M=D'+'\n'
	
	// * ARG = pop()
	result+='@SP'+'\n'
	result+='M=M-1'+'\n'
	result+='A=M'+'\n'
	result+='D=M'+'\n'
	result+='@ARG'+'\n'
	result+='A=M'+'\n'
	result+='M=D'+'\n'

	// SP = ARG+1 
	result+='@ARG'+'\n'
	result+='D=M'+'\n'
	result+='@SP'+'\n'
	result+='M=D+1'+'\n'

	//restoration of THAT, THIS, ARG, LCL
	result+=memory_restoration('THAT')
	result+=memory_restoration('THIS')
	result+=memory_restoration('ARG')
	result+=memory_restoration('LCL')
	
	// goto RET
	result+='@13'+'\n'
	result+='A=M'+'\n'
	result+='0; JMP'+'\n'
	return result
}

fn bootstrap()(string)
{
		mut str:='//bootstrapping'+'\n'
		str+='@256'+'\n'	//reset the stack pointer
		str+='D=A'+'\n'
		str+='@SP'+'\n'
		str+='M=D'+'\n'
		str+=call_fn('Sys.init','0','')
		return str
}

fn main() {
	mut path:=os.input("Enter the path")
	files := os.ls(path) or { println(err)return}
	filtered:=files.filter(it#[-3..]=='.vm')
	mut str:='' //reset the string of the Hack code
	if filtered.len>1 {
		str+=bootstrap()
	}
		folder:=path.split(r'\')
		folder_name:=folder#[-1..]
		mut newfile := os.create(path+r'\'+folder_name[0]+'.asm') or{println(err)return}
		newfile.write_string(str) or { println ( err ) return }

	for file in filtered //for each file
	{
		name:=file#[..-3] //the file name without ".vm"
		text := os.read_lines(path+r'\'+file) or {println(err)return}
		for line in text //for each line in file
		{
			str=''
			words:=line.split(' ')
			match words[0]{
				'add'{str+=add()}
				'sub'{str+=sub()}
				'neg'{str+=neg()}
				'eq'{str+=eq()}
				'gt'{str+=gt()}
				'lt'{str+=lt()}
				'and'{str+=and_fn()}
				'or'{str+=or_fn()}
				'not'{str+=not_fn()}
				'push'{str+=push(words[1],words[2],name)}
				'pop'{str+=pop(words[1],words[2].int(),name)}
				'label'{str+='//label '+words[1]+'\n'
					+'('+name+'.'+words[1]+')'+'\n'} //(filename.c)->label in Hack
				'goto'{str+='//goto '+words[1]+'\n'
					+'@'+name+'.'+words[1]+'\n'
					+'0;JMP'+'\n'}
				'if-goto'{str+=if_goto(words[1],name)}
				'call'{str+=call_fn(words[1],words[2],name)}
				'function'{str+=func_fn(words[1],words[2],name)}
				'return'{str+=ret()}
				else{str+=''}
			}
			newfile.write_string(str) or { println ( err ) return }
		}
	}
}

