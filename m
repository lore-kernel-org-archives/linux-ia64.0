From: Greg Harris <gregh@unify.com>
Date: Fri, 26 May 2000 15:27:49 +0000
Subject: [Linux-ia64] Linux IA-64 yacc error
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01BFC726.F32535D0"
Message-Id: <marc-linux-ia64-105590678205109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01BFC726.F32535D0
Content-Type: text/plain

Is this the correct forum for this question?

> Here is my problem. I am currently trying to build tools/src/nmake 
> on trillian machine(received from Intel) with linux as OS. Here is the
> error
> I get
> 
> yacc makey.y
> 
> yacc:f - out of space.
> 
> The machine has ample disk space.
> 
 We are  able to compile simple y file with existing yacc.   
> yacc is unable to handle complex
> file such as makey.y. 
> 
> 
> Greg Harris
> Senior Software Engineer (I18N)
> Unify Corporation <<makey.y>> 

------_=_NextPart_000_01BFC726.F32535D0
Content-Type: TEXT/plain;
	name="makey.y"
Content-Disposition: attachment;
	filename="makey.y"

%term number stop DEFINED
%term EQ NE LE GE LS RS
%term ANDAND OROR
%left ','
%right '='
%right '?' ':'
%left OROR
%left ANDAND
%left '|' '^'
%left '&'
%binary EQ NE
%binary '<' '>' LE GE
%left LS RS
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' UMINUS
%left '(' '.'
%%
S:	e stop	={return($1);}


e:	  e '*' e
		={$$ = $1 * $3;}
	| e '/' e
		={$$ = ($3 != 0) ? $1 / $3 : 0;}
	| e '%' e
		={$$ = ($3 != 0) ? $1 % $3 : 0;}
	| e '+' e
		={$$ = $1 + $3;}
	| e '-' e
		={$$ = $1 - $3;}
	| e LS e
		={$$ = $1 << $3;}
	| e RS e
		={$$ = $1 >> $3;}
	| e '<' e
		={$$ = $1 < $3;}
	| e '>' e
		={$$ = $1 > $3;}
	| e LE e
		={$$ = $1 <= $3;}
	| e GE e
		={$$ = $1 >= $3;}
	| e EQ e
		={$$ = $1 == $3;}
	| e NE e
		={$$ = $1 != $3;}
	| e '&' e
		={$$ = $1 & $3;}
	| e '^' e
		={$$ = $1 ^ $3;}
	| e '|' e
		={$$ = $1 | $3;}
	| e ANDAND e
		={$$ = $1 && $3;}
	| e OROR e
		={$$ = $1 || $3;}
	| e '?' e ':' e
		={$$ = $1 ? $3 : $5;}
	| e ',' e
		={$$ = $3;}
	| term
		={$$ = $1;}
term:
	  '-' term %prec UMINUS
		={$$ = -$2;}
	| '!' term
		={$$ = !$2;}
	| '~' term
		={$$ = ~$2;}
	| '(' e ')'
		={$$ = $2;}
	| DEFINED '(' number ')'
		={$$= $3;}
	| DEFINED number
		={$$ = $2;}
	| number
		={$$= $1;}
%%

------_=_NextPart_000_01BFC726.F32535D0--


