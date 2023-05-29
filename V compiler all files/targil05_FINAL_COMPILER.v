import os 
//Hodaya Rozental 315476523
//Shira Orbach 315234484

__global (
	line_counter    = int(1)
    class_counter    = int(0)
    static_counter    = int(0)
    field_counter    = int(0)
    argument_counter    = int(0)
    var_counter    = int(0)
    countlabels    = int(0)
    arr_op    = ['+','-','*','/','&amp;','|','&gt;','&lt;','=']
    symbol_table_class  =[][][]string{len:50}
    class_num_dictionary      = map[string]int{}  
    symbol_table_method  =[][]string{len:50}
)

/*
The function parses the tokens of the the EXPRESSION LIST derivation rule
*/
fn expression_list(file_text []string)([]string) {
    mut str:=''
    mut words:=file_text[line_counter].split(' ')
    mut counter:=0 //count the number of parameters
    if words[1]!=')'
    {
        str+=expression(file_text)
        counter++
        words=file_text[line_counter].split(' ')
        for
        {
            if words[1]!=','{break}
            line_counter++ // <symbol> , </symbol>
            str+=expression(file_text)
            counter++
            words=file_text[line_counter].split(' ')
        }
    }
    return [str,counter.str()]
}

/*
The function parses the tokens of the the TERM derivation rule
*/
fn term(file_text []string)(string) {
    mut str:=''
    mut kind:=''
    mut offset:=''
    mut words:=file_text[line_counter].split(' ')
    mut value:=words[1]
    match words[0]{
        '<integerConstant>'{  // <integerConstant> number </integerConstant>
            line_counter++
            str+='push constant '+value+'\n'
        } 
        '<stringConstant>'{  // <stringConstant> string </stringConstant>
            value=file_text[line_counter]#[17..-18]  //the string without the tags
            line_counter++
            str+='push constant '+  value.len.str()+'\n'
            str+='call String.new 1\n'
            mut temp:=0
            for i in 0..value.len             
             {          
	           temp= value[i] //the asci value
               str+='push constant '+temp.str()+'\n'
               str+='call String.appendChar 2\n'  
            }
         } 
        '<keyword>'{  // <keyword> true/false/null/this </keyword>
            line_counter++
            match value{
                'this'{str+='push pointer 0\n'}
                'true'{str+='push constant 0\n'
                    str+='not\n'
                }
                else{str+='push constant 0\n'} //null or false
            }
        } 
        '<identifier>'{
            next_tok:=file_text[line_counter+1].split(' ')
            if (next_tok[1]=='(') || (next_tok[1]=='.')
            {
                str+=subroutine_call(file_text)
            }
            else{
                name:=file_text[line_counter++].split(' ')[1]  // <identifier> varName </identifier>
                //if symbol_table_method.any(it[0]==name){
                    for i in 0..(var_counter+argument_counter){
                        if symbol_table_method[i][0]==name{
                            kind=symbol_table_method[i][2]
                            if kind=='var'{
                                kind='local'
                            }
                            offset=symbol_table_method[i][3]
                        }
                    }
                //}
                //else
                if kind==''{ //if varName is a class variable
                    for i in 0..(field_counter+static_counter){
                        if symbol_table_class[class_counter][i][0]==name{
                            kind=symbol_table_class[class_counter][i][2]
                            if kind=='field'{kind='this'}
                            offset=symbol_table_class[class_counter][i][3]
                        }
                    }
                }
                str+='push '+kind+' '+offset+'\n'
                if next_tok[1]=='['{
                    line_counter++ // <symbol> [ </symbol>
                    str+=expression(file_text)
                    line_counter++ // <symbol> ] </symbol>
                    str+='add\n' //varName[i]
                    str+='pop pointer 1\n'  //pop the adress of varName[i] 
                    str+='push that 0\n'    //push the value of varName[i] 
                }
            }
        }
        '<symbol>'{
            if words[1]=='('{
                line_counter++ // <symbol> ( </symbol>
                str+=expression(file_text)
                line_counter++ // <symbol> ) </symbol>
            }else{
                mut sign:=''
                if words[1]=='-'{
                    sign='neg\n'
                }else{sign='not\n'}  // ~
                line_counter++ // <symbol> -/~ </symbol>
                str+=term(file_text)+sign
            }
        }
        else{}
    }
    return str  
}



/*
The function parses the tokens of the the SUBROUTINE CALL derivation rule
*/
fn subroutine_call(file_text []string)(string) {
 
    mut kind:=''
    mut offset:=''
    mut str:=''
    mut func_name:=''
    mut method_flag:=0 //if method -> add 1 to the parameters number
    func_name+=file_text[line_counter++].split(' ')[1]  // <identifier> subroutineName/className/varName </identifier>
    next_tok:=file_text[line_counter].split(' ')
    if next_tok[1]=='.'{    
                for i in 0..(static_counter+field_counter){
                    if symbol_table_class[class_counter][i][0]==func_name{
                        method_flag=1
                        kind=symbol_table_class[class_counter][i][2]
                        if kind=='field'{
                                kind='this'
                            }
                        offset=symbol_table_class[class_counter][i][3]
                        func_name=symbol_table_class[class_counter][i][1] //save the objects class for the call
                        }
                }
                if kind==''{
                     for i in 0..(argument_counter+var_counter){
                    if symbol_table_method[i][0]==func_name{
                        method_flag=1
                        kind=symbol_table_method[i][2]
                        if kind=='var'{
                                kind='local'
                            }
                        offset=symbol_table_method[i][3]
                        func_name=symbol_table_method[i][1] //save the objects class for the call
                        }
                    }
                }
                if method_flag==1{
                    str+='push '+kind+' '+offset+'\n' //in case of obj.func()
                    }
                  
        func_name+=file_text[line_counter++].split(' ')[1]  // <symbol> . </symbol>
        func_name+=file_text[line_counter++].split(' ')[1]  // <identifier> subroutineName </identifier>
    }
    else
    {
        str+='push pointer 0\n'  //in case of func()
        method_flag=1
        func_name=class_num_dictionary.keys()[class_counter]+'.'+func_name
    }
    line_counter++ // <symbol> ( </symbol>
    ex_list:=expression_list(file_text)
    str+=ex_list[0]
    line_counter++ // <symbol> ) </symbol>
    str+='call '+func_name+' '+(ex_list[1].int()+method_flag).str()+'\n'  
    return str  
}


/*
The function parses the tokens of the the EXPRESSION derivation rule
*/
fn expression(file_text []string)(string) {
    mut str:=''
    str+=term(file_text)
    mut words:=file_text[line_counter].split(' ')
    for{
        if !(words[1] in arr_op){break}      
        line_counter++ // <symbol> operator </symbol>
        str+=term(file_text)
        match words[1] //operator
        {
            '+'{str+='add\n'}
            '-'{str+='sub\n'}
            '*'{str+='call Math.multiply 2\n'}
            '/'{str+='call Math.divide 2\n'}
            '&amp;'{str+='and\n'}
            '|'{str+='or\n'}
            '&gt;'{str+='gt\n'}
            '&lt;'{str+='lt\n'}
            '='{str+='eq\n'}
            else{}
        }
        words=file_text[line_counter].split(' ')
    }
    return str
}

/*
The function parses the tokens of the the RETURN STATEMENT derivation rule
*/
fn return_statement(file_text []string)(string) {
     mut str:=''
     mut x:=''
     line_counter++ //<keyword> return </keyword>
     mut words:=file_text[line_counter].split(' ')
     if words[1]!=';'
     {
         str+=expression(file_text)
     }
     else{
         str+='push constant 0\n'
     }
     line_counter++ // <symbol> ; </symbol>
     str+='return\n'
     return str
}


/*
The function parses the tokens of the the DO STATEMENT derivation rule
*/
fn do_statement(file_text []string)(string) {
     mut str:=''
     line_counter++ //<keyword> do </keyword>
     str+=subroutine_call(file_text)
     line_counter++// <symbol> ; </symbol>
     return str
}

/*
The function parses the tokens of the the WHILE STATEMENT derivation rule
*/
fn while_statement(file_text []string)(string) {
     mut str:=''
     line_counter++ // <keyword> while </keyword>
     line_counter++ // <symbol> ( </symbol>
     current_label:=countlabels++
     str+='label WHILE_EXP'+current_label.str()+'\n'
     str+=expression(file_text)
     line_counter++ // <symbol> ) </symbol>
     line_counter++ // <symbol> { </symbol>
     str+='not'+'\n'
     str+='if-goto WHILE_END'+current_label.str()+'\n'
     str+=statements(file_text)
     str+='goto WHILE_EXP'+current_label.str()+'\n'
     str+='label WHILE_END'+current_label.str()+'\n'
     line_counter++ // <symbol> } </symbol>
     return str
}


/*
The function parses the tokens of the the IF STATEMENT derivation rule
*/
fn if_statement(file_text []string)(string) {
     mut str:=''
     current_label:=countlabels++
     line_counter++ //<keyword> if </keyword>
     line_counter++ // <symbol> ( </symbol>
     str+=expression(file_text)
     str+='if-goto IF_TRUE'+current_label.str()+'\n'
     str+='goto IF_FALSE'+current_label.str()+'\n'
     line_counter++ // <symbol> ) </symbol>
     line_counter++ // <symbol> { </symbol>
     str+='label IF_TRUE'+current_label.str()+'\n'
     str+=statements(file_text)
     str+='goto IF_END'+current_label.str()+'\n'
     str+='label IF_FALSE'+current_label.str()+'\n'
     line_counter++ // <symbol> } </symbol>
     mut words:=file_text[line_counter].split(' ')
     if words[1]=='else'{
         line_counter++ //<keyword> else </keyword>
         line_counter++ // <symbol> { </symbol>
         str+=statements(file_text)
         line_counter++// <symbol> } </symbol>
     }
     str+='label IF_END'+current_label.str()+'\n'
     return str
}


/*
The function parses the tokens of the the LET STATEMENT derivation rule
*/
fn let_statement(file_text []string)(string) {
     mut str:=''
     mut kind:=''
     mut offset:=''
     line_counter++ //<keyword> let </keyword>
     name:=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
         for i in 0..(var_counter+argument_counter){
             if symbol_table_method[i][0]==name{
                 kind=symbol_table_method[i][2]
                 if kind=='var'{
                                kind='local'
                }
                 offset=symbol_table_method[i][3]
             }
         }
     if kind==''
     { //if varName is a class variable
          for i in 0..(static_counter+field_counter){
             if symbol_table_class[class_counter][i][0]==name{
                 kind=symbol_table_class[class_counter][i][2]
                 if kind=='field'{
                                kind='this'
                            }
                 offset=symbol_table_class[class_counter][i][3]
             }
         }
     }
    match kind 
     {
         'var'{kind='local'}
         'field'{kind='this'}
         //'static'{}
         //'argument'{}
          else{}
     }
     mut words:=file_text[line_counter].split(' ')
     if words[1]=='['{
         mut x:='push '+kind+' '+offset+'\n'
         line_counter++ // <symbol> [ </symbol>
         x+=expression(file_text)
         line_counter++ // <symbol> ] </symbol>
         x+='add\n'
         x+='pop pointer 1\n'
         kind='that'
         offset='0'
         line_counter++ // <symbol> = </symbol>
         str+=expression(file_text)
         str+=x
         str+='pop that 0'+'\n'
     }
else{
     line_counter++ // <symbol> = </symbol>
     str+=expression(file_text)
     str+='pop '+kind+' '+offset+'\n'
     }
     line_counter++ // <symbol> ; </symbol>
     return str
}

/*
The function parses the tokens of the the STATEMENTS derivation rule
*/
fn statements(file_text []string)(string) {
    mut str:=''
    mut words:=file_text[line_counter].split(' ')
    for
    {
        if !(words[0]=='<keyword>'){break}
        match words[1] {
            'let'{str+=let_statement(file_text)}
            'if'{str+=if_statement(file_text)}
            'while'{str+=while_statement(file_text)}
            'do'{str+=do_statement(file_text)
                str+='pop temp 0\n'    // ignore the return value
            }
            'return'{str+=return_statement(file_text)}
            else{}
        }
        words=file_text[line_counter].split(' ')
    }
    return str
}

/*
The function parses the tokens of the the VAR DEC derivation rule
*/
fn var_dec(file_text []string) {
    line_counter++//<keyword> var </keyword>
    mut type_:=file_text[line_counter++].split(' ')[1]  //<keyword> type </keyword>
    symbol_table_method[argument_counter+var_counter]=[]string{len:4}
    symbol_table_method[argument_counter+var_counter][1]=type_ 
    symbol_table_method[argument_counter+var_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
    symbol_table_method[argument_counter+var_counter][2]='var'
    symbol_table_method[argument_counter+var_counter][3]=(var_counter++).str()
    mut words:=file_text[line_counter].split(' ')
    for 
        {
                if !(words[1]==','){break}
                line_counter++ // <symbol> , </symbol>
                symbol_table_method[argument_counter+var_counter]=[]string{len:4}
                symbol_table_method[argument_counter+var_counter][1]=type_
                symbol_table_method[argument_counter+var_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
                symbol_table_method[argument_counter+var_counter][2]='var'
                symbol_table_method[argument_counter+var_counter][3]=(var_counter++).str()
                words=file_text[line_counter].split(' ')
        }
    line_counter++ // <symbol> ; </symbol>
}

/*
The function parses the tokens of the the SUBROUTINE BODY derivation rule
*/
fn subroutine_body(file_text []string, kind string)(string) {
    mut str:=''
    line_counter++// <symbol> { </symbol>
    mut words:=file_text[line_counter].split(' ')
    for {
        if !(words[1]=='var'){break}
        var_dec(file_text)
        words=file_text[line_counter].split(' ')
    }
    for i in 0..(argument_counter+var_counter){
                    }
    match kind {
        'constructor' {
            str+='push constant '+ field_counter.str()+'\n'
            str+='call Memory.alloc 1\n' 	
            str+='pop pointer 0\n' // = 'this'
        }
        'method' {
            str+='push argument 0\n'  
            str+='pop pointer 0\n'       //= RAM[THIS]  
        }
        else {}
    }
    str+=statements(file_text)
    line_counter++ // <symbol> } </symbol>
    return str
}

/*
The function parses the tokens of the the PARAMETER LIST derivation rule
*/
fn param_list(file_text []string,kind string) {
    symbol_table_method[0]=[]string{len:4}
    if kind=='method'{
        class_name:=class_num_dictionary.keys()[class_counter]
        symbol_table_method[0][0]='this'
        symbol_table_method[0][1]=class_name
        symbol_table_method[0][2]='argument'
        symbol_table_method[0][3]=(argument_counter++).str()
    }
    mut words:=file_text[line_counter].split(' ')
    if !(words[1]==')'){
        symbol_table_method[argument_counter]=[]string{len:4}
        symbol_table_method[argument_counter][1]=words[1] //<keyword> type </keyword>
        line_counter++
        symbol_table_method[argument_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
        symbol_table_method[argument_counter][2]='argument'
        symbol_table_method[argument_counter][3]=(argument_counter++).str()
        words=file_text[line_counter].split(' ')
        for 
        {
                if !(words[1]==','){break}
                line_counter++ // <symbol> , </symbol>
                symbol_table_method[argument_counter]=[]string{len:4}
                symbol_table_method[argument_counter][1]=file_text[line_counter++].split(' ')[1] //<keyword> type </keyword>
                symbol_table_method[argument_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
                symbol_table_method[argument_counter][2]='argument'
                symbol_table_method[argument_counter][3]=(argument_counter++).str()
                words=file_text[line_counter].split(' ')
        }
    }
}

/*
The function translates the tokens according to the CLASS VAR DEC derivation rule
*/
fn parse_class_var_dec(file_text []string) {
    mut words:=file_text[line_counter].split(' ')
    mut kind:=''
    mut type_:=''
    for 
        {
            if !((words[1]=='static') || (words[1]=='field')){break}
            symbol_table_class[class_counter][field_counter+static_counter]=[]string{len:4}
            symbol_table_class[class_counter][field_counter+static_counter][2]=words[1] //<keyword> field or static </keyword>
            kind=words[1] //field or static
            line_counter++
            type_=file_text[line_counter].split(' ')[1]  //<keyword> type </keyword>
            symbol_table_class[class_counter][field_counter+static_counter][1]= type_
            line_counter++
            symbol_table_class[class_counter][field_counter+static_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
            if kind=='field'{
                symbol_table_class[class_counter][field_counter+static_counter][3]=(field_counter++).str()
            }else{
                symbol_table_class[class_counter][field_counter+static_counter][3]=(static_counter++).str()
                }
           
            words=file_text[line_counter].split(' ')
            for 
            {
                if !(words[1]==','){break}
                line_counter++ // <symbol> , </symbol>
                symbol_table_class[class_counter][field_counter+static_counter]=[]string{len:4}
                symbol_table_class[class_counter][field_counter+static_counter][2]=kind 
                symbol_table_class[class_counter][field_counter+static_counter][1]=type_
                symbol_table_class[class_counter][field_counter+static_counter][0]=file_text[line_counter++].split(' ')[1] //<identifier> varName </identifier>
                if kind=='field'{
                    symbol_table_class[class_counter][field_counter+static_counter][3]=(field_counter++).str()
                }else{
                    symbol_table_class[class_counter][field_counter+static_counter][3]=(static_counter++).str()
                    }
                words=file_text[line_counter].split(' ')
            }	
            line_counter++ // <symbol> ; </symbol>
            words=file_text[line_counter].split(' ')
        }  
}

/*
The function translates the tokens according to the PARSE SUB DEC derivation rule
*/
fn parse_sub_dec(file_text []string)(string) {
    mut str:=''
    symbol_table_method=[][]string{len:50}
    argument_counter=0
    var_counter=0
    class_name:=class_num_dictionary.keys()[class_counter]
    kind:=file_text[line_counter++].split(' ')[1] //<keyword> constructor or function or method </keyword>
    line_counter++ //<keyword> type or void </keyword>
    func_name:=file_text[line_counter++].split(' ')[1] //<identifier> subroutineName </identifier>
    line_counter++ // <symbol> ( </symbol>
    param_list(file_text,kind)
    line_counter++ // <symbol> ) </symbol>
    str+=subroutine_body(file_text,kind)
    return 'function '+class_name+'.'+func_name+' '+var_counter.str()+'\n'+str

}

/*
The function translates the tokens according to the CLASS derivation rule
*/
fn parse_class(file []string)(string) {
    symbol_table_class[class_counter]=[][]string{len:50}
    mut str:=''
    line_counter++  //<keyword> class </keyword>
    mut words:=file[line_counter++].split(' ') //<identifier> classname </identifier>
    static_counter=0
    field_counter=0
    class_num_dictionary[words[1]]=class_counter
    //symbol_table_class[class_counter]=[][]string{len:50}
    line_counter++  //<symbol> { </symbol>
	parse_class_var_dec(file)
	words=file[line_counter].split(' ')
    for{
        if words[1]=='}'{break}
        str+=parse_sub_dec(file)
        words=file[line_counter].split(' ')
    }
	line_counter++  //<symbol> } </symbol>
    class_counter++
    return str
}

fn main() {
	mut path:=os.input("Enter the path")
	files:= os.ls(path) or { println(err)return}
	mut str:='' //reset the string of the code
	filtered:=files.filter(it#[-6..]=='T1.xml')
	for file in filtered //for each file
	{
        line_counter=1
		name:=file#[..-6] //the file name without 'T1.xml'
	    mut newfile := os.create(path+r'\'+name+'.vm') or{println(err)return} //create xml file
        text := os.read_lines(path+r"\"+file) or {println(err)return}
        str+=parse_class(text)
	    newfile.write_string(str) or { println ( err ) return }
        str=''
    }
}