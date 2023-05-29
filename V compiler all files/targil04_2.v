import os 
//Hodaya Rozental 315476523
//Shira Orbach 315234484

__global (
	line_counter    = int(1)
    arr_op    = ['+','-','*','/','&amp;','|','&gt;','&lt;','=']
)

/*
The function parses the tokens of the the EXPRESSION LIST derivation rule
*/
fn expression_list(file_text []string)(string) {
    mut str:='<expressionList>\n'
    mut words:=file_text[line_counter].split(' ')
    if words[1]!=')'
    {
        str+=expression(file_text)
        words=file_text[line_counter].split(' ')
        for
        {
            if words[1]!=','{break}
            str+=file_text[line_counter++]+'\n' // <symbol> , </symbol>
            str+=expression(file_text)
            words=file_text[line_counter].split(' ')
        }
    }
    str+='</expressionList>\n'
    return str
}

/*
The function parses the tokens of the the TERM derivation rule
*/
fn term(file_text []string)(string) {
    mut str:='<term>\n'
    mut words:=file_text[line_counter].split(' ')
    match words[0]{
        '<integerConstant>'{str+=file_text[line_counter++]+'\n'} // <integerConstant> number </integerConstant>
        '<stringConstant>'{str+=file_text[line_counter++]+'\n'} // <stringConstant> string </stringConstant>
        '<keyword>'{str+=file_text[line_counter++]+'\n'} // <keyword> true/false/null/this </keyword>
        '<identifier>'{
            next_tok:=file_text[line_counter+1].split(' ')
            if (next_tok[1]=='(') || (next_tok[1]=='.')
            {
                str+=subroutine_call(file_text)
            }
            else{
                str+=file_text[line_counter++]+'\n' // <identifier> varName </identifier>
                if next_tok[1]=='['{
                    str+=file_text[line_counter++]+'\n' // <symbol> [ </symbol>
                    str+=expression(file_text)
                    str+=file_text[line_counter++]+'\n' // <symbol> ] </symbol>
                }
               
            }
        }
        '<symbol>'{
            if words[1]=='('{
                str+=file_text[line_counter++]+'\n' // <symbol> ( </symbol>
                str+=expression(file_text)
                str+=file_text[line_counter++]+'\n' // <symbol> ) </symbol>
            }else{
                str+=file_text[line_counter++]+'\n' // <symbol> -/~ </symbol>
                str+=term(file_text)
            }
        }

        else{}
    }



    str+='</term>\n'
    return str
    
}



/*
The function parses the tokens of the the SUBROUTINE CALL derivation rule
*/
fn subroutine_call(file_text []string)(string) {
    mut str:=''
    str+=file_text[line_counter++]+'\n' // <identifier> subroutineName/className/varName </identifier>
    next_tok:=file_text[line_counter].split(' ')
    if next_tok[1]=='.'{
        str+=file_text[line_counter++]+'\n' // <symbol> . </symbol>
        str+=file_text[line_counter++]+'\n' // <identifier> subroutineName </identifier>
    }
    str+=file_text[line_counter++]+'\n' // <symbol> ( </symbol>
    str+=expression_list(file_text)
    str+=file_text[line_counter++]+'\n' // <symbol> ) </symbol>
    return str  
}

/*
The function parses the tokens of the the EXPRESSION derivation rule
*/
fn expression(file_text []string)(string) {
    mut str:='<expression>\n'
    str+=term(file_text)
    mut words:=file_text[line_counter].split(' ')
    for{
        if !(words[1] in arr_op){break}
        str+=file_text[line_counter++]+'\n' // <symbol> operator </symbol>
        str+=term(file_text)
        words=file_text[line_counter].split(' ')
    }
    str+='</expression>\n'
    return str
}

/*
The function parses the tokens of the the RETURN STATEMENT derivation rule
*/
fn return_statement(file_text []string)(string) {
     mut str:='<returnStatement>\n'
     str+=file_text[line_counter++]+'\n' //<keyword> return </keyword>
     mut words:=file_text[line_counter].split(' ')
     if words[1]!=';'
     {
         str+=expression(file_text)
     }
     str+=file_text[line_counter++]+'\n' // <symbol> ; </symbol>
     str+='</returnStatement>\n'
     return str
}


/*
The function parses the tokens of the the DO STATEMENT derivation rule
*/
fn do_statement(file_text []string)(string) {
     mut str:='<doStatement>\n'
     str+=file_text[line_counter++]+'\n' //<keyword> do </keyword>
     str+=subroutine_call(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> ; </symbol>
     str+='</doStatement>\n'
     return str
}

/*
The function parses the tokens of the the WHILE STATEMENT derivation rule
*/
fn while_statement(file_text []string)(string) {
     mut str:='<whileStatement>\n'
     str+=file_text[line_counter++]+'\n' //<keyword> while </keyword>
     str+=file_text[line_counter++]+'\n' // <symbol> ( </symbol>
     str+=expression(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> ) </symbol>
     str+=file_text[line_counter++]+'\n' // <symbol> { </symbol>
     str+=statements(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> } </symbol>
     str+='</whileStatement>\n'
     return str
}


/*
The function parses the tokens of the the IF STATEMENT derivation rule
*/
fn if_statement(file_text []string)(string) {
     mut str:='<ifStatement>\n'
     str+=file_text[line_counter++]+'\n' //<keyword> if </keyword>
     str+=file_text[line_counter++]+'\n' // <symbol> ( </symbol>
     str+=expression(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> ) </symbol>
     str+=file_text[line_counter++]+'\n' // <symbol> { </symbol>
     str+=statements(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> } </symbol>
     mut words:=file_text[line_counter].split(' ')
     if words[1]=='else'{
         str+=file_text[line_counter++]+'\n' //<keyword> else </keyword>
         str+=file_text[line_counter++]+'\n' // <symbol> { </symbol>
         str+=statements(file_text)
         str+=file_text[line_counter++]+'\n' // <symbol> } </symbol>
     }
     str+='</ifStatement>\n'
     return str
}


/*
The function parses the tokens of the the LET STATEMENT derivation rule
*/
fn let_statement(file_text []string)(string) {
     mut str:='<letStatement>\n'
     str+=file_text[line_counter++]+'\n' //<keyword> let </keyword>
     str+=file_text[line_counter++]+'\n' //<identifier> varName </identifier>
     mut words:=file_text[line_counter].split(' ')
     if words[1]=='['{
         str+=file_text[line_counter++]+'\n' // <symbol> [ </symbol>
         str+=expression(file_text)
         str+=file_text[line_counter++]+'\n' // <symbol> ] </symbol>
     }
     str+=file_text[line_counter++]+'\n' // <symbol> = </symbol>
     str+=expression(file_text)
     str+=file_text[line_counter++]+'\n' // <symbol> ; </symbol>
     str+='</letStatement>\n'
     return str
}

/*
The function parses the tokens of the the STATEMENTS derivation rule
*/
fn statements(file_text []string)(string) {
    mut str:='<statements>\n'
    mut words:=file_text[line_counter].split(' ')
    for
    {
        if !(words[0]=='<keyword>'){break}
        match words[1] {
            'let'{str+=let_statement(file_text)}
            'if'{str+=if_statement(file_text)}
            'while'{str+=while_statement(file_text)}
            'do'{str+=do_statement(file_text)}
            'return'{str+=return_statement(file_text)}
            else{}
        }
        words=file_text[line_counter].split(' ')
    }
    str+='</statements>\n'
    return str
}

/*
The function parses the tokens of the the VAR DEC derivation rule
*/
fn var_dec(file_text []string)(string) {
    mut str:='<varDec>\n'
    str+=file_text[line_counter++]+'\n' //<keyword> var </keyword>
    str+=file_text[line_counter++]+'\n' //<keyword> type </keyword>
    str+=file_text[line_counter++]+'\n' //<identifier> varName </identifier>
    mut words:=file_text[line_counter].split(' ')
    for 
        {
                if !(words[1]==','){break}
                str+=file_text[line_counter++]+'\n' // <symbol> , </symbol>
                str+=file_text[line_counter++]+'\n' // <identifier> varName </identifier>
                words=file_text[line_counter].split(' ')
        }
    str+=file_text[line_counter++]+'\n' // <symbol> ; </symbol>
    str+='</varDec>\n'
    return str
}

/*
The function parses the tokens of the the SUBROUTINE BODY derivation rule
*/
fn subroutine_body(file_text []string)(string) {
    mut str:='<subroutineBody>\n'
    str+=file_text[line_counter++]+'\n' // <symbol> { </symbol>
    mut words:=file_text[line_counter].split(' ')
    for {
        if !(words[1]=='var'){break}
        str+=var_dec(file_text)
        words=file_text[line_counter].split(' ')
    }
    str+=statements(file_text)
    str+=file_text[line_counter++]+'\n' // <symbol> } </symbol>
    str+='</subroutineBody>\n'
    return str
}

/*
The function parses the tokens of the the PARAMETER LIST derivation rule
*/
fn param_list(file_text []string)(string) {
    mut str:='<parameterList>\n'
    mut words:=file_text[line_counter].split(' ')
    if words[0]=='<keyword>'{
        str+=file_text[line_counter++]+'\n' //<keyword> type </keyword>
        str+=file_text[line_counter++]+'\n' //<identifier> varName </identifier>
        words=file_text[line_counter].split(' ')
        for 
        {
                if !(words[1]==','){break}
                str+=file_text[line_counter++]+'\n' // <symbol> , </symbol>
                str+=file_text[line_counter++]+'\n' //<keyword> type </keyword>
                str+=file_text[line_counter++]+'\n' // <identifier> varName </identifier>
                words=file_text[line_counter].split(' ')
        }
    }
    str+='</parameterList>\n'
    return str
}

/*
The function translates the tokens according to the CLASS VAR DEC derivation rule
*/
fn parse_class_var_dec(file_text []string)(string) {
    mut str:=''
    mut words:=file_text[line_counter].split(' ')
    for 
        {
            if !((words[1]=='static') || (words[1]=='field')){break}
            str+='<classVarDec>\n'
            str+=file_text[line_counter++]+'\n' //<keyword> field or static </keyword>
            str+=file_text[line_counter++]+'\n' //<keyword> type </keyword>
            str+=file_text[line_counter++]+'\n' //<identifier> varName </identifier>
            words=file_text[line_counter].split(' ')
            for 
            {
                if !(words[1]==','){break}
                str+=file_text[line_counter++]+'\n' // <symbol> , </symbol>
                str+=file_text[line_counter++]+'\n' // <identifier> varName </identifier>
                words=file_text[line_counter].split(' ')
            }	
            str+=file_text[line_counter++]+'\n' // <symbol> ; </symbol>
            str+= '</classVarDec>\n'
            words=file_text[line_counter].split(' ')
        }  
    return str
}

/*
The function translates the tokens according to the PARSE SUB DEC derivation rule
*/
fn parse_sub_dec(file_text []string)(string) {
    mut str:='<subroutineDec>\n'
    str+=file_text[line_counter++]+'\n' //<keyword> constructor or function or method </keyword>
    str+=file_text[line_counter++]+'\n' //<keyword> type or void </keyword>
    str+=file_text[line_counter++]+'\n' //<identifier> subroutineName </identifier>
    str+=file_text[line_counter++]+'\n' // <symbol> ( </symbol>
    str+=param_list(file_text)
    str+=file_text[line_counter++]+'\n' // <symbol> ) </symbol>
    str+=subroutine_body(file_text)
    str+='</subroutineDec>\n'
    return str

}

/*
The function translates the tokens according to the CLASS derivation rule
*/
fn parse_class(file []string)(string) {
    mut str:=''
	str+='<class>\n'
    str+=file[line_counter++]+'\n'  //<keyword> class </keyword>
    str+=file[line_counter++]+'\n' //<identifier> classname </identifier>
    str+=file[line_counter++]+'\n'  //<symbol> { </symbol>
 

	str+=parse_class_var_dec(file)
	mut words:=file[line_counter].split(' ')
    for{
        if words[1]=='}'{break}
        str+=parse_sub_dec(file)
        words=file[line_counter].split(' ')
    }
	
	str+=file[line_counter++]+'\n'  //<symbol> } </symbol>
	str+= '</class>'+'\n'
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
	    mut newfile := os.create(path+r'\'+name+'1.xml') or{println(err)return} //create xml file
        text := os.read_lines(path+r"\"+file) or {println(err)return}
        str+=parse_class(text)
	    newfile.write_string(str) or { println ( err ) return }
        str=''
    }
}