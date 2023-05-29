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
The func translate the Neg command from vm to asm and return it as a string
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
The func translate the Gt command from vm to asm and return it as a string
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
The func translate the Lt command from vm to asm and return it as a string
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
The func translate the Eq command from vm to asm and return it as a string
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

fn main() {
	path:=os.input("Enter the path")
	files := os.ls(path) or { println(err)return}
	filtered:=files.filter(it#[-3..]=='.vm')
	for file in filtered //for each file
	{
		name:=file#[..-3] //the file name without ".vm"
		mut newfile := os.create(name+'.asm') or{println(err)return}
		text := os.read_lines(path+r'\'+file) or {println(err)return}
		for line in text //for each line in file
		{
			words:=line.split(' ')
			mut str:=''
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
				else{str+=''}
			}
			newfile.write_string(str) or { println ( err ) return }
		}
	}
}
