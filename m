From: "Story, Shane" <shane.story@intel.com>
Date: Tue, 08 Aug 2000 19:36:50 +0000
Subject: [Linux-ia64] Problem report: gas breaks on fclass mnemonics
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C0016F.FF2ADA50"
Message-Id: <marc-linux-ia64-105590678205284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C0016F.FF2ADA50
Content-Type: text/plain;
	charset="iso-8859-1"

The problem is that the Linux assembler (2.9-ia64-000216) apparently does
not support the mnemonics
used with the fclass instructions (@inf, @pos, @neg, @zero, @qnan, @snan,
@norm, @unorm).  
When we replace these mnemonics with their hexadecimal equivalents all is
well. A test case is
attached as shar file:

 <<problem.report>> 
Can the IA-64 assembler support folks let me know if this is a known problem
or if  they need any 
further information?

Thanks,
Shane Story ( 503- 696-3229)


------_=_NextPart_000_01C0016F.FF2ADA50
Content-Type: application/octet-stream;
	name="problem.report"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="problem.report"

=0A=
# This is a shell archive.  Remove anything before this line,=0A=
# then unpack it by saving it in a file and typing "sh file".=0A=
#=0A=
# Wrapped by Shane Story <shane@orono> on Tue Aug  8 12:25:14 2000=0A=
#=0A=
# This archive contains:=0A=
#	test.c		logf_bad.s	logf_ok.s	makefile	=0A=
#=0A=
=0A=
LANG=3D""; export LANG=0A=
PATH=3D/bin:/usr/bin:/usr/sbin:/usr/ccs/bin:$PATH; export PATH=0A=
=0A=
echo x - test.c=0A=
cat >test.c <<'@EOF'=0A=
float  logf (float  x);=0A=
main()=0A=
{=0A=
typedef union fp_single =0A=
{=0A=
   float                 val;=0A=
   unsigned int          hilo;=0A=
} unionsingle; =0A=
=0A=
unionsingle  fzd, ffd, fxd, fyd;=0A=
int i, nbr_of_single_errors=3D0;=0A=
unsigned int out1_in1_single_values[2][2] =3D =0A=
{=0A=
	{ 0xff800000, 0x80000000},=0A=
	{ 0xff800000, 0x00000000}=0A=
};=0A=
for( i=3D0; i<2; i++ )=0A=
{=0A=
	fzd.hilo   =3D out1_in1_single_values[i][0];=0A=
	fxd.hilo   =3D out1_in1_single_values[i][1];=0A=
	ffd.val    =3D logf(fxd.val);=0A=
	if( fzd.hilo !=3D ffd.hilo )=0A=
	{=0A=
	printf("LOGF [%d]\n",i);=0A=
	printf("ERROR: out gold in: %8.8lx   %8.8lx   %8.8lx\n",=0A=
	ffd.hilo, fzd.hilo, fxd.hilo);=0A=
	printf("ERROR: out gold in: %+12.7e  %+12.7e  %+12.7e\n",=0A=
	ffd.val,fzd.val,fxd.val);=0A=
	nbr_of_single_errors++;=0A=
	}=0A=
}=0A=
if(nbr_of_single_errors =3D=3D 0) printf("----- LOGF PASSED. -----\n"); =
=0A=
else printf("LOGF nbr_of_single_errors: %d\n",nbr_of_single_errors);=0A=
}=0A=
void __libm_error_support(void *arg1,void *arg2,void *retval,int =
input_tag)=0A=
{return;}=0A=
@EOF=0A=
=0A=
chmod 644 test.c=0A=
=0A=
=0A=
rm -f /tmp/uud$$=0A=
(echo "begin 666 /tmp/uud$$\n#;VL*n#6%@x\n \nend" | uudecode) =
>/dev/null 2>&1=0A=
if [ X"`cat /tmp/uud$$ 2>&1`" =3D Xok ]=0A=
then=0A=
	unpacker=3Duudecode=0A=
else=0A=
	echo Compiling unpacker for non-ascii files=0A=
	pwd=3D`pwd`; cd /tmp=0A=
	cat >unpack$$.c <<'EOF'=0A=
#include <stdio.h>=0A=
#define C (*p++ - ' ' & 077)=0A=
main()=0A=
{=0A=
	int n;=0A=
	char buf[128], *p, a,b;=0A=
=0A=
	scanf("begin %o ", &n);=0A=
	gets(buf);=0A=
=0A=
	if (freopen(buf, "w", stdout) =3D=3D NULL) {=0A=
		perror(buf);=0A=
		exit(1);=0A=
	}=0A=
=0A=
	while (gets(p=3Dbuf) && (n=3DC)) {=0A=
		while (n>0) {=0A=
			a =3D C;=0A=
			if (n-- > 0) putchar(a << 2 | (b=3DC) >> 4);=0A=
			if (n-- > 0) putchar(b << 4 | (a=3DC) >> 2);=0A=
			if (n-- > 0) putchar(a << 6 | C);=0A=
		}=0A=
	}=0A=
	exit(0);=0A=
}=0A=
EOF=0A=
	cc -o unpack$$ unpack$$.c=0A=
	rm unpack$$.c=0A=
	cd $pwd=0A=
	unpacker=3D/tmp/unpack$$=0A=
fi=0A=
rm -f /tmp/uud$$=0A=
=0A=
echo x - logf_bad.s '[non-ascii]'=0A=
$unpacker <<'@eof'=0A=
begin 600 logf_bad.s=0A=
M+F9I;&4@(FQO9V8N<R(-"@T*#0HO+R!#;W!Y<FEG:'0@*&,I(#(P,# L($ENX=0A=
M=3D&5L($-O<G!O<F%T:6]N#0HO+R!!;&P@<FEG:'1S(')E<V5R=3DF5D+@T*+R\-X=0A=
M"B\O($-O;G1R:6)U=3D&5D(#(O,B\R,# P(&)Y($IO:&X@2&%R<FES;VXL(%1EX=0A=
M9"!+=3D6)A<VMA+"!";V(@3F]R:6XL(%-H86YE(%-T;W)Y+ T*+R\@86YD(%!IX=0A=
M;F<@5&%K(%!E=3D&5R(%1A;F<@;V8@=3D&AE($-O;7!U=3D&%T:6]N86P@4V]F=3D'=3DAX=
=0A=
M<F4@3&%B+"!);G1E;"!#;W)P;W)A=3D&EO;BX-"B\O#0HO+R!705)204Y462!$X=0A=
M25-#3$%)3452#0HO+PT*+R\@5$A)4R!33T945T%212!)4R!04D]6241%1"!"X=0A=
M62!42$4@0T]065))1TA4($A/3$1%4E,@04Y$($-/3E1224)55$]24PT*+R\@X=0A=
M(D%3($E3(B!!3D0@04Y9($584%)%4U,@3U(@24U03$E%1"!705)204Y42453X=0A=
M+"!)3D-,541)3D<L($)55"!.3U0-"B\O($Q)34E4140@5$\L(%1(12!)35!,X=0A=
M245$(%=3D!4E)!3E1)15,@3T8@34520TA!3E1!0DE,2519($%.1"!&251.15-3X=0A=
M($9/4@T*+R\@02!005)424-53$%2(%!54E!/4T4@05)%($1)4T-,04E-140NX=0A=
M($E.($Y/($5614Y4(%-(04Q,($E.5$5,($]2($E44PT*+R\@0T].5%))0E54X=0A=
M3U)3($)%($Q)04),12!&3U(@04Y9($1)4D5#5"P@24Y$25)%0U0L($E.0TE$X=0A=
M14Y404PL(%-014-)04PL#0HO+R!%6$5-4$Q!4EDL($]2($-/3E-%455%3E1)X=0A=
M04P@1$%-04=3D%4R H24Y#3%5$24Y'+"!"550@3D]4($Q)34E4140@5$\L#0HOX=0A=
M+R!04D]#55)%345.5"!/1B!354)35$E4551%($=3D/3T13($]2(%-%4E9)0T53X=0A=
M.R!,3U-3($]&(%5312P@1$%402P@3U(-"B\O(%!23T9)5%,[($]2($)54TE.X=0A=
M15-3($E.5$524E505$E/3BD@2$]7159%4B!#0553140@04Y$($].($%.62!4X=0A=
M2$5/4ED-"B\O($]&($Q)04))3$E462P@5TA%5$A%4B!)3B!#3TY44D%#5"P@X=0A=
M4U1224-4($Q)04))3$E462!/4B!43U)4("A)3D-,541)3D<-"B\O($Y%1TQ)X=0A=
M1T5.0T4@3U(@3U1(15)725-%*2!!4DE324Y'($E.($%.62!705D@3U54($]&X=0A=
M(%1(12!54T4@3T8@5$A)4PT*+R\@4T]&5%=3D!4D4L($5614X@248@041625-%X=0A=
M1"!/1B!42$4@4$]34TE"24Q)5%D@3T8@4U5#2"!$04U!1T4N#0HO+PT*+R\@X=0A=
M26YT96P@0V]R<&]R871I;VX@:7,@=3D&AE(&%U=3D&AO<B!O9B!T:&ES(&-O9&4LX=0A=
M(&%N9"!R97%U97-T<R!T:&%T(&%L; T*+R\@<')O8FQE;2!R97!O<G1S(&]RX=0A=
M(&-H86YG92!R97%U97-T<R!B92!S=3D6)M:71T960@=3D&\@:70@9&ER96-T;'D@X=0A=
M870-"B\O(&AT=3D' Z+R]D979E;&]P97(N:6YT96PN8V]M+V]P96YS;W5R8V4NX=0A=
M#0H@#0HO+PT*+R\@07-S96UB;'D@;6%C<F]S#0HO+ST]/3T]/3T]/3T]/3T]X=0A=
M/3T]/3T]/3T]/3T]/3T]/3T]/3T]/3T]/3T]#0H-"B\O(&EN=3D&5G97(@<F5GX=0A=
M:7-T97)S('5S960-"@T*($Q/1U]!1%]#3T5&1B @(" @(" @(" @(" @(#T@X=0A=
M<C,S#0H@3$]'7T%$7T-/3E-404Y44R @(" @(" @(" @/2!R,S0-"B!,3T=3D?X=0A=
M;6%S:R @(" @(" @(" @(" @(" @(" ]('(S-0T*#0H@3$]'7T9&1C<@(" @X=0A=
M(" @(" @(" @(" @(" @/2!R,S8-"B!,3T=3D?8FEA<R @(" @(" @(" @(" @X=0A=
M(" @(" ]('(S-PT*($Q/1U]X7VX@(" @(" @(" @(" @(" @(" @(#T@<C,XX=0A=
M#0H@3$]'7WA?:6YD(" @(" @(" @(" @(" @(" @/2!R,SD-"B!,3T=3D?>%]SX=0A=
M97AP(" @(" @(" @(" @(" @(" ]('(T, T*#0H@1U)?4T%615]"," @(" @X=0A=
M(" @(" @(" @(" @/2!R-#$-"B!'4E]3059%7U!&4R @(" @(" @(" @(" @X=0A=
M(" ]('(T,@T*($=3D27U-!5D5?1U @(" @(" @(" @(" @(" @(#T@<C0S#0H-X=0A=
M"B!'4E]087)A;65T97)?6" @(" @(" @(" @(" @(" ]('(T- T*($=3D27U!AX=0A=
M<F%M971E<E]9(" @(" @(" @(" @(" @(#T@<C0U#0H@1U)?4&%R86UE=3D&5RX=0A=
M7U)%4U5,5" @(" @(" @(" @/2!R-#8-"B!,3T=3D?=3D&%G(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" ]('(T-PT*#0H-"@T*#0H-"B\O(&9L;V%T:6YG('!O:6YTX=0A=
M(')E9VES=3D&5R<R!U<V5D#0H-"B!L;V=3D?8V]E9F9?<#,@(" @(" @(" @(" @X=0A=
M(" @/2!F,S(-"B!L;V=3D?8V]E9F9?<#(@(" @(" @(" @(" @(" @/2!F,S,-X=0A=
M"B!L;V=3D?8V]E9F9?<#$@(" @(" @(" @(" @(" @/2!F,S0-"B!L;V=3D?8V]NX=0A=
M<W1?;&]G,B @(" @(" @(" @(" @/2!F,S4-"@T*(&QO9U]T:')E<VAH;VQDX=0A=
M(" @(" @(" @(" @(" ](&8S-@T*(&QO9U]"(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" ](&8S-PT*(&QO9U]R(" @(" @(" @(" @(" @(" @(" @(" ](&8SX=0A=
M. T*(&QO9U]P;VQY7W Q(" @(" @(" @(" @(" @(" ](&8S.0T*(&QO9U]RX=0A=
M<W$@(" @(" @(" @(" @(" @(" @(" ](&8T, T*#0H@;&]G7W!O;'E?<#(@X=0A=
M(" @(" @(" @(" @(" @(#T@9C0Q#0H@;&]G7W!O;'E?<#,@(" @(" @(" @X=0A=
M(" @(" @(#T@9C0R#0H@;&]G7VX@(" @(" @(" @(" @(" @(" @(" @(#T@X=0A=
M9C0S#0H@;&]G7U0@(" @(" @(" @(" @(" @(" @(" @(#T@9C0T#0H@;&]GX=0A=
M7W,@(" @(" @(" @(" @(" @(" @(" @(#T@9C0U#0H-"B!L;V=3D?<&]L>5]QX=0A=
M,2 @(" @(" @(" @(" @(" @/2!F-#8-"B!L;V=3D?<W-Q(" @(" @(" @(" @X=0A=
M(" @(" @(" @/2!F-#<-"B!L;V=3D?86)S7W,@(" @(" @(" @(" @(" @(" @X=0A=
M/2!F-#@-"B!L;V=3D?<&]L>5]Q,B @(" @(" @(" @(" @(" @/2!F-#D-"B!LX=0A=
M;V=3D?>%]N;W)M(" @(" @(" @(" @(" @(" @/2!F-3 -"@T*(&QO9U]I;G9?X=0A=
M;&XQ," @(" @(" @(" @(" @(" ](&8U,0T*(&QO9S$P7V8X(" @(" @(" @X=0A=
M(" @(" @(" @(" ](&8U,@T*#0HN9&%T80T*#0HN86QI9VX@,38-"@T*#0ILX=0A=
M;V=3D?8V]E9F9?=3D&%B;&4Z#0ID871A." P>&)F9# P,#$P,#AF,SED-3D@(" @X=0A=
M("\O(' S#0ID871A." P>#-F9#4U-38P-S-E,&,T-6$@(" @("\O(' R#0H-X=0A=
M"FQO9U]C;VYS=3D&%N=3D'-?=3D&%B;&4Z#0ID871A." P>&)F9&9F9F9F9F9F865AX=0A=
M,34@(" @+R\@<#$-"F1A=3D&$X(#!X,V9E-C)E-#)F969A,SEE9B @(" O+R!,X=0A=
M;V<H,BD-"F1A=3D&$X(#!X,V8W,# P,# P,# P,# P," @(" O+R R7BTX+"!TX=0A=
M:')E<VAH;VQD#0ID871A." P>#-F9&)C8C=3DB,34R-F4U,&4@(" @+R\@,2]LX=0A=
M;C$P#0H-"F1A=3D&$X(#!X,T8V,# T,#$U-40U.#@Y12 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" @,"\R-38I#0ID871A." P>#-&-S@Q,C$R,30U.#9"-30@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @(#$O,C4V*0T*9&%T83@@,'@S1C@T,3DR.48YX=0A=
M-C@S,D8P(" @("\O;&]G*#$O9G)C<&$H,2L@(" R+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T8X0S,Q-S,X-$,W-48P-B @(" O+VQO9R@Q+V9R8W!A*#$K(" @,R\R-38IX=0A=
M#0ID871A." P>#-&.3%!-D(Y,4%#-S,S.#8@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @(#0O,C4V*0T*9&%T83@@,'@S1CDU0D$Y035$.4%#,#,Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(" U+S(U-BD-"F1A=3D&$X(#!X,T8Y.40R03@P-S0S,C5&X=0A=
M-" @(" O+VQO9R@Q+V9R8W!A*#$K(" @-B\R-38I#0ID871A." P>#-&.40VX=0A=
M0C(W,C4Y-SDX,#(@(" @+R]L;V<H,2]F<F-P82@Q*R @(#<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D$P0S4X1D$Q.41&04%!(" @("\O;&]G*#$O9G)C<&$H,2L@(" XX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9!,CDU-$,W.$-"0T4Q0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" @.2\R-38I#0ID871A." P>#-&031!.31$,D1!.39#-38@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,3 O,C4V*0T*9&%T83@@,'@S1D$V-T,Y-$8RX=0A=
M1#1"0C4X(" @("\O;&]G*#$O9G)C<&$H,2L@(#$Q+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9!.#4Q.#A"-C,P1C V." @(" O+VQO9R@Q+V9R8W!A*#$K(" Q,B\R-38IX=0A=
M#0ID871A." P>#-&04$V0CA!0D4W,T%&-$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,3,O,C4V*0T*9&%T83@@,'@S1D%#-#0Q13 V1C<R03E%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#$T+S(U-BD-"F1A=3D&$X(#!X,T9!13%%-C<Q,S8P-D0PX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(" Q-2\R-38I#0ID871A." P>#-&049&X=0A=
M038Y,3%!0CDS,#$@(" @+R]L;V<H,2]F<F-P82@Q*R @,38O,C4V*0T*9&%TX=0A=
M83@@,'@S1D(P14,Q,SE#-41!-C Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#$WX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9",41"1#(V-#-$,3DP0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Q."\R-38I#0ID871A." P>#-&0C)#0S<R.#1&135&,4,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,3DO,C4V*0T*9&%T83@@,'@S1D(S0D1&-4$WX=0A=
M1#%%138T(" @("\O;&]G*#$O9G)C<&$H,2L@(#(P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9"-$(P-40W04$P,3)%," @(" O+VQO9R@Q+V9R8W!A*#$K(" R,2\R-38IX=0A=
M#0ID871A." P>#-&0C4X,$1"-T-%0C4W,#(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,C(O,C4V*0T*9&%T83@@,'@S1D(V-S1&,#@Y,S8U03=3D!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#(S+S(U-BD-"F1A=3D&$X(#!X,T9"-S8Y148R0S9"-38XX=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(" R-"\R-38I#0ID871A." P>#-&0C@UX=0A=
M1D0Y,C<U,#9!-#@@(" @+R]L;V<H,2]F<F-P82@Q*R @,C4O,C4V*0T*9&%TX=0A=
M83@@,'@S1D(Y,S,U135$-3DT.3@Y(" @("\O;&]G*#$O9G)C<&$H,2L@(#(VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9"03)",#(R,$,X135&-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" R-R\R-38I#0ID871A." P>#-&0D(P,# T04,Q03@V04,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,C@O,C4V*0T*9&%T83@@,'@S1D)"1CDV.#<VX=0A=
M.49#03$Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#(Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9"0T-&141"1D5%,3-!." @(" O+VQO9R@Q+V9R8W!A*#$K(" S,"\R-38IX=0A=
M#0ID871A." P>#-&0D1!-S(W-C,X-#0V03(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,S$O,C4V*0T*9&%T83@@,'@S1D)%03,R-3=3D&13$P1C=3D!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#,R+S(U-BD-"F1A=3D&$X(#!X,T9"1C=3D"13E&141"1D1%X=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(" S,R\R-38I#0ID871A." P>#-&0S RX=0A=
M04(S-3)&1C(U1C0@(" @+R]L;V<H,2]F<F-P82@Q*R @,S0O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,P.3=3D#134W.40R,#1$(" @("\O;&]G*#$O9G)C<&$H,2L@(#,UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#,3$W.$4X,C(W130W0R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" S-B\R-38I#0ID871A." P>#-&0S$X-3<T-T1"14-&,S0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,S<O,C4V*0T*9&%T83@@,'@S1D,Q1C-".3(UX=0A=
M1C(U1#0Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#,X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#,C8R-40Q139$1$8U-R @(" O+VQO9R@Q+V9R8W!A*#$K(" S.2\R-38IX=0A=
M#0ID871A." P>#-&0S)$,38Q,$,X-C@Q,T$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-# O,C4V*0T*9&%T83@@,'@S1D,S-#!#-3DW-#$Q-#)%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#0Q+S(U-BD-"F1A=3D&$X(#!X,T9#,T(P.$(V-S4W1C)!X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(" T,B\R-38I#0ID871A." P>#-&0S0PX=0A=
M1$9",#@S-S@P,#,@(" @+R]L;V<H,2]F<F-P82@Q*R @-#,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,T-T4W-$4X0T$U1C=3D#(" @("\O;&]G*#$O9G)C<&$H,2L@(#0TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#-$5&-3%&-C0V-D1%-" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" T-2\R-38I#0ID871A." P>#-&0S4V,#DR13 R0D$U,38@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-#8O,C4V*0T*9&%T83@@,'@S1D,U1#(S.#4WX=0A=
M0T0W-$0U(" @("\O;&]G*#$O9G)C<&$H,2L@(#0W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#-C,Q,T$S-S,S-40W-B @(" O+VQO9R@Q+V9R8W!A*#$K(" T."\R-38IX=0A=
M#0ID871A." P>#-&0S9!,SDY1$%"0D0S.#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-#DO,C4V*0T*9&%T83@@,'@S1D,W,#,S-T1$,T-%-#%"(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#4P+S(U-BD-"F1A=3D&$X(#!X,T9#-S<V-30Q,CA&-C$RX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(" U,2\R-38I#0ID871A." P>#-&0S=3D%X=0A=
M.40X,D$P0C R,D0@(" @+R]L;V<H,2]F<F-P82@Q*R @-3(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,X-$$V0C<U.48U,3)&(" @("\O;&]G*#$O9G)C<&$H,2L@(#4SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#.$%"-#=3D$-48U03,Q," @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" U-"\R-38I#0ID871A." P>#-&0SDQ1D4T.3 Y-C4X,4(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-34O,C4V*0T*9&%T83@@,'@S1D,Y.#$V,S0PX=0A=
M,3%!03<U(" @("\O;&]G*#$O9G)C<&$H,2L@(#4V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#.48V0S0P-S X.38V-" @(" O+VQO9R@Q+V9R8W!A*#$K(" U-R\R-38IX=0A=
M#0ID871A." P>#-&0T$U.$4W,CDS-#A&-#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-3@O,C4V*0T*9&%T83@@,'@S1D-!0D(U-4,S,38Y,T%$(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#4Y+S(U-BD-"F1A=3D&$X(#!X,T9#0C%%,3 T.3$Y149$X=0A=
M," @(" O+VQO9R@Q+V9R8W!A*#$K(" V,"\R-38I#0ID871A." P>#-&0T(YX=0A=
M-$5%.3-%,S8W0T(@(" @+R]L;V<H,2]F<F-P82@Q*R @-C$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D-"1C@U,4,P-C<U-35&(" @("\O;&]G*#$O9G)C<&$H,2L@(#8RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#0S5#,#(U-$)&,C-!-B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" V,R\R-38I#0ID871A." P>#-&0T-#,# P0SE$0C-#-3(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-C0O,C4V*0T*9&%T83@@,'@S1D-$,C0T1#DYX=0A=
M0S@U-C<T(" @("\O;&]G*#$O9G)C<&$H,2L@(#8U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#1#@X13DS1D(R1C0U," @(" O+VQO9R@Q+V9R8W!A*#$K(" V-B\R-38IX=0A=
M#0ID871A." P>#-&0T1%1$0T,S=3D%045&,#$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-C<O,C4V*0T*9&%T83@@,'@S1D-%-3,P149&13<Q,#$R(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#8X+S(U-BD-"F1A=3D&$X(#!X,T9#14(X.4$Q-C0X0CDWX=0A=
M,2 @(" O+VQO9R@Q+V9R8W!A*#$K(" V.2\R-38I#0ID871A." P>#-&0T8QX=0A=
M13<U1D%$1CE"1$4@(" @+R]L;V<H,2]F<F-P82@Q*R @-S O,C4V*0T*9&%TX=0A=
M83@@,'@S1D-&.#1!,S)%040W0S,U(" @("\O;&]G*#$O9G)C<&$H,2L@(#<QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#1D5",C(S,T5!,#=3D#1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" W,B\R-38I#0ID871A." P>#-&1# R.$8Y0S<P,S5#,4,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-S,O,C4V*0T*9&%T83@@,'@S1D0P-4,X0D4PX=0A=
M1#DV,S5!(" @("\O;&]G*#$O9G)C<&$H,2L@(#<T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,#@U14(X1CA!13<Y-R @(" O+VQO9R@Q+V9R8W!A*#$K(" W-2\R-38IX=0A=
M#0ID871A." P>#-&1#!".4,X13,R1#$Y,3$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-S8O,C4V*0T*9&%T83@@,'@S1D0P141$,#8P0C<X,#@Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#<W+S(U-BD-"F1A=3D&$X(#!X,T9$,3(R,#(T0T8P,#8SX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(" W."\R-38I#0ID871A." P>#-&1#$TX=0A=
M0D4R.3(W045#1#0@(" @+R]L;V<H,2]F<F-P82@Q*R @-SDO,C4V*0T*9&%TX=0A=
M83@@,'@S1D0Q.# V,3A%1C$X041&(" @("\O;&]G*#$O9G)C<&$H,2L@(#@PX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$,4(U,$)"13)&0S8S0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" X,2\R-38I#0ID871A." P>#-&1#%$1C1#0S=3D#1C(T,D0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @.#(O,C4V*0T*9&%T83@@,'@S1D0R,30T-39$X=0A=
M,$5".$0T(" @("\O;&]G*#$O9G)C<&$H,2L@(#@S+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,C-%0S4Y.3%%0D$T.2 @(" O+VQO9R@Q+V9R8W!A*#$K(" X-"\R-38IX=0A=
M#0ID871A." P>#-&1#(W-#!$.48X-S!!1D(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @.#4O,C4V*0T*9&%T83@@,'@S1D0R.45#1$%"0T1&03 T(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#@V+S(U-BD-"F1A=3D&$X(#!X,T9$,D0T-C8P,D%$0T-%X=0A=
M12 @(" O+VQO9R@Q+V9R8W!A*#$K(" X-R\R-38I#0ID871A." P>#-&1#)&X=0A=
M1C8V0C T14$Y1#0@(" @+R]L;V<H,2]F<F-P82@Q*R @.#@O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0S,S4U,#1",S4U03,W(" @("\O;&]G*#$O9G)C<&$H,2L@(#@YX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$,S8P.3(U14,T-$8U1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Y,"\R-38I#0ID871A." P>#-&1#,X0D8Q0S,S,S=3D%-S4@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @.3$O,C4V*0T*9&%T83@@,'@S1D0S0S(U,C<WX=0A=
M,S,S,3@T(" @("\O;&]G*#$O9G)C<&$H,2L@(#DR+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,T5$1C0V,T,Q-C@S12 @(" O+VQO9R@Q+V9R8W!A*#$K(" Y,R\R-38IX=0A=
M#0ID871A." P>#-&1#0Q.4(T,C-$-44X0S<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @.30O,C4V*0T*9&%T83@@,'@S1D0T-#4Y,44P-3,Y1C0Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#DU+S(U-BD-"F1A=3D&$X(#!X,T9$-#=3D#.3$W-4(V1C!!X=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(" Y-B\R-38I#0ID871A." P>#-&1#1!X=0A=
M.$(S-#$U-3)",#D@(" @+R]L;V<H,2]F<F-P82@Q*R @.3<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0T1#1&,SDP.#DP,4$P(" @("\O;&]G*#$O9G)C<&$H,2L@(#DXX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$-3 Q-3(X1$$Q1CDV." @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Y.2\R-38I#0ID871A." P>#-&1#4R1$0P-C,T-T0T1C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,# O,C4V*0T*9&%T83@@,'@S1D0U-4$V1#-#X=0A=
M-T(X03A!(" @("\O;&]G*#$O9G)C<&$H,2L@,3 Q+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$-3DR-40R0C$Q,D$U.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$P,B\R-38IX=0A=
M#0ID871A." P>#-&1#5"1C0P-D(U-#-$0C(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,#,O,C4V*0T*9&%T83@@,'@S1D0U14,T,S-$-4,S-4%%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3 T+S(U-BD-"F1A=3D&$X(#!X,T9$-C$Y-C5#1$(P,D,QX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$P-2\R-38I#0ID871A." P>#-&1#8TX=0A=
M-D$X-#DS-4(R03(@(" @+R]L;V<H,2]F<F-P82@Q*R Q,#8O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0V-S0P041$,S%$13DT(" @("\O;&]G*#$O9G)C<&$H,2L@,3 WX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$-D$Q.$1"-S1!-3A#-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$P."\R-38I#0ID871A." P>#-&1#9#1C,Q,#4X-C<P14,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,#DO,C4V*0T*9&%T83@@,'@S1D0V1C$X,$4XX=0A=
M-3)&,$)!(" @("\O;&]G*#$O9G)C<&$H,2L@,3$P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$-S%&-40W,4(X.31&," @(" O+VQO9R@Q+V9R8W!A*#$K(#$Q,2\R-38IX=0A=
M#0ID871A." P>#-&1#<T1#5!149$-C9$-4,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,3(O,C4V*0T*9&%T83@@,'@S1D0W-T(W.3DR,D)$,S=3D%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3$S+S(U-BD-"F1A=3D&$X(#!X,T9$-T$Y0CDX.#E&,3E%X=0A=
M,B @(" O+VQO9R@Q+V9R8W!A*#$K(#$Q-"\R-38I#0ID871A." P>#-&1#=3D$X=0A=
M.#%",#,W14(V038@(" @+R]L;V<H,2]F<F-P82@Q*R Q,34O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0X,#8Y13,S.#(W,C,Q(" @("\O;&]G*#$O9G)C<&$H,2L@,3$VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$.#(Y.39$,T5&.$)#0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$Q-R\R-38I#0ID871A." P>#-&1#@U.#4U-S<V1$-"1D(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,3@O,C4V*0T*9&%T83@@,'@S1D0X.#<S-C4XX=0A=
M,S(W0T-&(" @("\O;&]G*#$O9G)C<&$H,2L@,3$Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$.$%!-S4Y-S-!0CA#1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$R,"\R-38IX=0A=
M#0ID871A." P>#-&1#A$.3DR1$,X.#(T134@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,C$O,C4V*0T*9&%T83@@,'@S1D0Y,#A$,D5!-T0Y-3$R(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3(R+S(U-BD-"F1A=3D&$X(#!X,T9$.3)#-3E%-SE#,$4UX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$R,R\R-38I#0ID871A." P>#-&1#DUX=0A=
M0D0W-3!%13-%1#,@(" @+R]L;V<H,2]F<F-P82@Q*R Q,C0O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0Y.$(W.#$Q03-%135"(" @("\O;&]G*#$O9G)C<&$H,2L@,3(UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$.4%&-#=3D&,S-$-# V0R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$R-B\R-38I#0ID871A." P>#-&1#E$1C(W,$,Q.3$T03@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,C<O,C4V*0T*9&%T83@@,'@S1D1!,#,R-45$X=0A=
M,31&1$$T(" @("\O;&]G*#$O9G)C<&$H,2L@,3(X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$03,S-#0P,C(T1D$W.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$R.2\R-38IX=0A=
M#0ID871A." P>#-&1$$U-S<R-44X,$,S.#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,S O,C4V*0T*9&%T83@@,'@S1D1!.#=3D$,#$V-41$,3DY(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3,Q+S(U-BD-"F1A=3D&$X(#!X,T9$04%#,D4V0S S1C@YX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$S,B\R-38I#0ID871A." P>#-&1$%$X=0A=
M0T-#-D9$1C9!.#$@(" @+R]L;V<H,2]F<F-P82@Q*R Q,S,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1",#$U0C-%0C%%-SDP(" @("\O;&]G*#$O9G)C<&$H,2L@,3,TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$0C,R,T$S038S-3DT." @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$S-2\R-38I#0ID871A." P>#-&1$(U-D9!,#0T-C(Y,#D@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,S8O,C4V*0T*9&%T83@@,'@S1D1".#@Q04$VX=0A=
M-3E"0SDS(" @("\O;&]G*#$O9G)C<&$H,2L@,3,W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$0D%$,$)%1C-$0C$V-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$S."\R-38IX=0A=
M#0ID871A." P>#-&1$)$,C$R.3<W.#%#,D8@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,SDO,C4V*0T*9&%T83@@,'@S1D1#,#,Y,C,V1C X.#$Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,30P+S(U-BD-"F1A=3D&$X(#!X,T9$0S(X0T(Q131$,S)&X=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(#$T,2\R-38I#0ID871A." P>#-&1$,TX=0A=
M13$Y0C@T-S(S0S(@(" @+R]L;V<H,2]F<F-P82@Q*R Q-#(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1#-T9&.4,W-#4U-$,Y(" @("\O;&]G*#$O9G)C<&$H,2L@,30SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$0T$U-T(V-$4Y1$(P-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$T-"\R-38I#0ID871A." P>#-&1$-#0C$S,$$U0T5"0C @(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-#4O,C4V*0T*9&%T83@@,'@S1D1#1C!#,$0QX=0A=
M.$8S,C9&(" @("\O;&]G*#$O9G)C<&$H,2L@,30V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$1#(S,C W-4(U03(P,2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$T-R\R-38IX=0A=
M#0ID871A." P>#-&1$0T.3 R-#9$149!-D(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-#@O,C4V*0T*9&%T83@@,'@S1D1$-D5&03DQ.$0R-4-$(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,30Y+S(U-BD-"F1A=3D&$X(#!X,T9$1#DU,#DW,#=3D!134RX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$U,"\R-38I#0ID871A." P>#-&1$1"X=0A=
M0C)%1D4Y,D,U-30@(" @+R]L;V<H,2]F<F-P82@Q*R Q-3$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1$144R1C,T-#5%-$%&(" @("\O;&]G*#$O9G)C<&$H,2L@,34RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$13$T.$$Q03(W,C9#12 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$U,R\R-38I#0ID871A." P>#-&1$4S049#,$$T.49&-# @(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-30O,C4V*0T*9&%T83@@,'@S1D1%-C$X-3(PX=0A=
M-D0U,39%(" @("\O;&]G*#$O9G)C<&$H,2L@,34U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$13@X,C4W.#@R,T0U,B @(" O+VQO9R@Q+V9R8W!A*#$K(#$U-B\R-38IX=0A=
M#0ID871A." P>#-&1$5!141$,D5!0SDY,$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-3<O,C4V*0T*9&%T83@@,'@S1D1%1#5!0S5&-#,V0D4S(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,34X+S(U-BD-"F1A=3D&$X(#!X,T9$149#.3,R-D0Q-D%"X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$U.2\R-38I#0ID871A." P>#-&1$8RX=0A=
M,SDQ03(Q-3<V,# @(" @+R]L;V<H,2]F<F-P82@Q*R Q-C O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1&-$%!-T5%,#,Q.3)$(" @("\O;&]G*#$O9G)C<&$H,2L@,38QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$1C<Q1#8R-T,S,$)"," @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$V,B\R-38I#0ID871A." P>#-&1$8Y.3%#-D-",T(S-SD@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-C,O,C4V*0T*9&%T83@@,'@S1D1&0S W041!X=0A=
M-CE!.3$P(" @("\O;&]G*#$O9G)C<&$H,2L@,38T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$1D4W1C$X14(P,T0S12 @(" O+VQO9R@Q+V9R8W!A*#$K(#$V-2\R-38IX=0A=
M#0ID871A." P>#-&13 P-T,P-3-#-3 P,D4@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-C8O,C4V*0T*9&%T83@@,'@S1D4P,4(Y-#(Q.3A!-4$Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,38W+S(U-BD-"F1A=3D&$X(#!X,T9%,#)&-S0T,#!#-C1%X=0A=
M0B @(" O+VQO9R@Q+V9R8W!A*#$K(#$V."\R-38I#0ID871A." P>#-&13 TX=0A=
M,S8P0D4W-C S040@(" @+R]L;V<H,2]F<F-P82@Q*R Q-CDO,C4V*0T*9&%TX=0A=
M83@@,'@S1D4P-3<U.4%#-#=3D&13,T(" @("\O;&]G*#$O9G)C<&$H,2L@,3<PX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,#9"-48Q.3$Q0T8U,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$W,2\R-38I#0ID871A." P>#-&13 W.$)&,#4S,T,U-C@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-S(O,C4V*0T*9&%T83@@,'@S1D4P.$-$.38XX=0A=
M-T4W0C!%(" @("\O;&]G*#$O9G)C<&$H,2L@,3<S+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,$$Q,# W-$-&.3 Q.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$W-"\R-38IX=0A=
M#0ID871A." P>#-&13!"-3,T,T$R,S0T-S<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-S4O,C4V*0T*9&%T83@@,'@S1D4P0SDW-$,X.30S,4-%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3<V+S(U-BD-"F1A=3D&$X(#!X,T9%,$1$0S(S,#5".3@XX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$W-R\R-38I#0ID871A." P>#-&13!%X=0A=
M0C4R-$)!1D,Y,3@@(" @+R]L;V<H,2]F<F-P82@Q*R Q-S@O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4P1D9"-30R,3-!-#<V(" @("\O;&]G*#$O9G)C<&$H,2L@,3<YX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,3$T,C4S1$$Y-T0Y1B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$X,"\R-38I#0ID871A." P>#-&13$R.$$R-$8Q1#E!1D8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.#$O,C4V*0T*9&%T83@@,'@S1D4Q,S8U,C4RX=0A=
M0D8P.#8U(" @("\O;&]G*#$O9G)C<&$H,2L@,3@R+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,31!134U.$(T03DR1" @(" O+VQO9R@Q+V9R8W!A*#$K(#$X,R\R-38IX=0A=
M#0ID871A." P>#-&13$U1C@U03$Y0S<V-4(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q.#0O,C4V*0T*9&%T83@@,'@S1D4Q-D0T1#,X0S$Q.49!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3@U+S(U-BD-"F1A=3D&$X(#!X,T9%,3@R,#-#,C!$1#$SX=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#$X-B\R-38I#0ID871A." P>#-&13$YX=0A=
M-D,W0D,T0C%&,T(@(" @+R]L;V<H,2]F<F-P82@Q*R Q.#<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4Q031!-S,X0C=3D!,S-#(" @("\O;&]G*#$O9G)C<&$H,2L@,3@XX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,4(Y.#%#,$,Y-C4S1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$X.2\R-38I#0ID871A." P>#-&13%#138Y13A"0C$P-D(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.3 O,C4V*0T*9&%T83@@,'@S1D4Q1$,V,3E$X=0A=
M13 V.30T(" @("\O;&]G*#$O9G)C<&$H,2L@,3DQ+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,48Q-C!!,D%$,$1!-" @(" O+VQO9R@Q+V9R8W!A*#$K(#$Y,B\R-38IX=0A=
M#0ID871A." P>#-&13(P-C9$-S<T,#<S-T4@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q.3,O,C4V*0T*9&%T83@@,'@S1D4R,30W1$)!-#=3D!,SDT(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3DT+S(U-BD-"F1A=3D&$X(#!X,T9%,C(Y03%"0S5%0D%#X=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#$Y-2\R-38I#0ID871A." P>#-&13(SX=0A=
M-T,Q.#0Q034P,D4@(" @+R]L;V<H,2]F<F-P82@Q*R Q.38O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4R-$-&0T4V1C@P1#E!(" @("\O;&]G*#$O9G)C<&$H,2L@,3DWX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,C5",D,U-4-$-3<V,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$Y."\R-38I#0ID871A." P>#-&13(W,#=3D&-$0U1C=3D#-#$@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.3DO,C4V*0T*9&%T83@@,'@S1D4R.#5%,#@TX=0A=
M,D-!,S@T(" @("\O;&]G*#$O9G)C<&$H,2L@,C P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,CDT,CDT-S X0C<W,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(P,2\R-38IX=0A=
M#0ID871A." P>#-&13)!.4$R-C<P049&,$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,#(O,C4V*0T*9&%T83@@,'@S1D4R0C=3D&0C)#.$0Q0T,Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C S+S(U-BD-"F1A=3D&$X(#!X,T9%,D,V-4$V,SDU1C5&X=0A=
M-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(P-"\R-38I#0ID871A." P>#-&13)$X=0A=
M0D8U-3=3D",$1&-#,@(" @+R]L;V<H,2]F<F-P82@Q*R R,#4O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4R14$V-$,S1CDW-C4U(" @("\O;&]G*#$O9G)C<&$H,2L@,C VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,S P,3@R,S8X-$0W,R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(P-R\R-38I#0ID871A." P>#-&13,P13DW13E!.$(U0T0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,#@O,C4V*0T*9&%T83@@,'@S1D4S,C0V,T5"X=0A=
M1$0S-$5!(" @("\O;&]G*#$O9G)C<&$H,2L@,C Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,S,R1C0S,31!1#<Y-B @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q,"\R-38IX=0A=
M#0ID871A." P>#-&13,T.$0Y,$4W-#8T1# @(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,3$O,C4V*0T*9&%T83@@,'@S1D4S-3<W.48X0S0S1#9%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C$R+S(U-BD-"F1A=3D&$X(#!X,T9%,S8V,C$Y-C%!-D$YX=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q,R\R-38I#0ID871A." P>#-&13,WX=0A=
M0S(Y.48S0S,V-D$@(" @+R]L;V<H,2]F<F-P82@Q*R R,30O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4S.$%%,C$W,3DW-D4W(" @("\O;&]G*#$O9G)C<&$H,2L@,C$UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,SDY03$U-T$V,#-%-R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(Q-B\R-38I#0ID871A." P>#-&13-!1D-#1D4W-T(Y1#$@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,3<O,C4V*0T*9&%T83@@,'@S1D4S0D4Y1#4PX=0A=
M,S4S,T(U(" @("\O;&]G*#$O9G)C<&$H,2L@,C$X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,T-$-S0X,$(T03A!,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q.2\R-38IX=0A=
M#0ID871A." P>#-&13-%,T,T,SDQ.$8W-D,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,C O,C4V*0T*9&%T83@@,'@S1D4S1C)!0T(R-T5$-D,W(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C(Q+S(U-BD-"F1A=3D&$X(#!X,T9%-# Q.4,R,3(U0T$YX=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(R,B\R-38I#0ID871A." P>#-&130QX=0A=
M.#$P-C$S.#DW,C(@(" @+R]L;V<H,2]F<F-P82@Q*R R,C,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4T,C<Q,34Q.$1&-30U(" @("\O;&]G*#$O9G)C<&$H,2L@,C(TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-#,V,3DT13$R0C9"1B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(R-2\R-38I#0ID871A." P>#-&130T-3(X-40V.$5!-CD@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,C8O,C4V*0T*9&%T83@@,'@S1D4T-4)#0S0VX=0A=
M-$,X.3-!(" @("\O;&]G*#$O9G)C<&$H,2L@,C(W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-#9!140R,48Q,3=3D&0R @(" O+VQO9R@Q+V9R8W!A*#$K(#(R."\R-38IX=0A=
M#0ID871A." P>#-&130W03$U,C=3D%.$$R1#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,CDO,C4V*0T*9&%T83@@,'@S1D4T.#DT-#5%1D9&0T-#(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C,P+S(U-BD-"F1A=3D&$X(#!X,T9%-$$P,3A"0T(V.3@SX=0A=
M-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(S,2\R-38I#0ID871A." P>#-&131!X=0A=
M1C5!,$,Y1#8U1#<@(" @+R]L;V<H,2]F<F-P82@Q*R R,S(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4T0D5!,D$U0D1"13@W(" @("\O;&]G*#$O9G)C<&$H,2L@,C,SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-$-$1C(X1C$P04,T-B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(S-"\R-38I#0ID871A." P>#-&131$1#0Y0T8Y.30P-3@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,S4O,C4V*0T*9&%T83@@,'@S1D4T14-!.#9%X=0A=
M-C1!-C@T(" @("\O;&]G*#$O9G)C<&$H,2L@,C,V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-3 S0S0S0T0X14(V." @(" O+VQO9R@Q+V9R8W!A*#$K(#(S-R\R-38IX=0A=
M#0ID871A." P>#-&134Q,S,U-C8V-T9#-3<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,S@O,C4V*0T*9&%T83@@,'@S1D4U,C)!13 W,SA!,T0X(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C,Y+S(U-BD-"F1A=3D&$X(#!X,T9%-3,R,D4R-C@V-S@UX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(#(T,"\R-38I#0ID871A." P>#-&134TX=0A=
M,4(U0T(Y-SDX,#D@(" @+R]L;V<H,2]F<F-P82@Q*R R-#$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4U-3$T-$9$0D-"1#8R(" @("\O;&]G*#$O9G)C<&$H,2L@,C0RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-38P1$)#-#4Q-3-#-R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(T,R\R-38I#0ID871A." P>#-&134W,#=3D!,C9"0CA#-C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R-#0O,C4V*0T*9&%T83@@,'@S1D4U.#=3D&-C!%X=0A=
M1#5".3 P(" @("\O;&]G*#$O9G)C<&$H,2L@,C0U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-3DW03<Y-S=3D#.$8S,2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(T-B\R-38IX=0A=
M#0ID871A." P>#-&135!-S8P1#8S-$)".$(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R-#<O,C4V*0T*9&%T83@@,'@S1D4U0C<R,40R.35&,3!&(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C0X+S(U-BD-"F1A=3D&$X(#!X,T9%-4,V14$Y-#0S,45&X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(T.2\R-38I#0ID871A." P>#-&135$X=0A=
M-D)",C)%03@V1C8@(" @+R]L;V<H,2]F<F-P82@Q*R R-3 O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4U138Y,S@V-#5$,SDP(" @("\O;&]G*#$O9G)C<&$H,2L@,C4QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-48V-S-#-C%!,D5$,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(U,B\R-38I#0ID871A." P>#-&138P-C5"14$S.#4Y,C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R-3,O,C4V*0T*9&%T83@@,'@S1D4V,38T0D9!X=0A=
M-T-#,#9"(" @("\O;&]G*#$O9G)C<&$H,2L@,C4T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-C(V-#-&14-&.3<T,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(U-2\R-38IX=0A=
M#0H-"BYG;&]B86P@;&]G9@T*+F=3DL;V)A;"!L;V<Q,&8-"@T*+G1E>'0-"BYPX=0A=
M<F]C("!L;V<Q,&8-"BYA;&EG;B S,@T*;&]G,3!F.@T*#0I[(" @(" N;69IX=0A=
M#0H@(" @(&%L;&]C(" @(" @<C,R(" @(" @(" @(" ](&%R+G!F<RPQ+#$QX=0A=
M+#0L, T*(" @("!F<F-P82YS,2 @;&]G7T(L<#$U(" @(" @/2 @("!F,2QFX=0A=
M. T*(" @("!A9&1L(" @(" @3$]'7T%$7T-/149&(" @/2 @("! ;'1O9F8HX=0A=
M;&]G7V-O969F7W1A8FQE*2QG< T*?0T*>R @(" @+FUF:0T*(" @("!M;W8@X=0A=
M(" @(" @3$]'7VUA<VL@(" @(" @(" @(" ](" @(#!X,49&1D8-"B @(" @X=0A=
M9FYO<FTN<S$@(&QO9U]X7VYO<FT@(" @(" @(" @/2 @("!F. T*(" @("!AX=0A=
M9&1L(" @(" @3$]'7T%$7T-/3E-404Y44R @(" ](" @($!L=3D&]F9BAL;V=3D?X=0A=
M8V]N<W1A;G1S7W1A8FQE*2QG<#L[#0I]#0H-"GL@(" @("YM9FD-"B @(" @X=0A=
M;6]V(" @(" @(" @(" @3$]'7T9&1C<@(#T@(" @,'A&1D8W#0H@(" @(&9CX=0A=
M;&%S<RYM+G5N8R @(' X+' P(" @(" ](" @(&8X+$!Z97)O#0H@(" @('-HX=0A=
M<B @(" @(" @(" @($Q/1U]B:6%S(" ](" @($Q/1U]M87-K+#$-"GT-"GL@X=0A=
M(" @("YM9FD-"B @(" @;F]P+FT@(" @(" @(" @(" @(" @(#DY.0T*(" @X=0A=
M("!F;7,N<S$@(" @;&]G7W,@(" @(" @(" @/2 @("!F,2QF."QF,0T*(" @X=0A=
M("!C;7 N97$@(" @<#8L<#<@(" @(" @(" @/2 @("!R,"QR," [.R -"GT-X=0A=
M"@T*>R @(" @+FUF:0T*(" @("!L9#@@(" @(" @3$]'7T%$7T-/149&(" @X=0A=
M/2 @("!;3$]'7T%$7T-/149&70T*(" @("!N;W N9B @(" @(" @(" @(" @X=0A=
M(" @(" @(" Y.3D-"B @(" @;F]P+FD@(" @(" @(" @(" @(" @(" @(" @X=0A=
M.3DY#0I]#0I[(" @(" N;69B#0H@(" @(&QD." @(" @("!,3T=3D?041?0T].X=0A=
M4U1!3E13(" @(#T@(" @6TQ/1U]!1%]#3TY35$%.5%-=3D#0H@(" @(&YO<"YFX=0A=
M(" @(" @(" @(" @(" @(" @(" @(" @(" @.3DY#0H@(" @(&)R+G-P=3D&L@X=0A=
M("!,3T=3D&7TQ/1S$P1E]#3TU-3TX-"GT-"@T*#0HN96YD<"!L;V<Q,&8-"@T*X=0A=
M#0HN=3D&5X=3D T*+G!R;V,@(&QO9V8-"BYA;&EG;B S,@T*;&]G9CH-"@T*#0I[X=0A=
M(" @(" N;69I( T*(" @("!A;&QO8R @(" @('(S,B @(" @(" @(" @/2!AX=0A=
M<BYP9G,L,2PQ,2PT+# -"B @(" @9G)C<&$N<S$@(&QO9U]"+' Q-2 @(" @X=0A=
M(#T@(" @9C$L9C@-"B @(" @861D;" @(" @($Q/1U]!1%]#3T5&1B @(#T@X=0A=
M(" @0&QT;V9F*&QO9U]C;V5F9E]T86)L92DL9W -"GT@#0I[(" @(" N;69IX=0A=
M( T*(" @("!M;W8@(" @(" @3$]'7VUA<VL@(" @(" @(" @(" ](" @(#!XX=0A=
M,49&1D8-"B @(" @9FYO<FTN<S$@(&QO9U]X7VYO<FT@(" @(" @(" @/2 @X=0A=
M("!F. T*(" @("!A9&1L(" @(" @3$]'7T%$7T-/3E-404Y44R @(" ](" @X=0A=
M($!L=3D&]F9BAL;V=3D?8V]N<W1A;G1S7W1A8FQE*2QG<#L[#0I]#0H-"B -"GL@X=0A=
M(" @("YM9FD@#0H@(" @(&UO=3DB @(" @(" @(" @($Q/1U]&1D8W(" ](" @X=0A=
M(#!X1D9&-PT*(" @("!F8VQA<W,N;2YU;F,@("!P."QP," @(" @/2 @("!FX=0A=
M."Q >F5R;PT*(" @("!S:'(@(" @(" @(" @("!,3T=3D?8FEA<R @/2 @("!,X=0A=
M3T=3D?;6%S:RPQ#0I]( T*>R @(" @+FUF:2 -"B @(" @;F]P+FT@(" @(" @X=0A=
M(" @(" @(" @(#DY.0T*(" @("!F;7,N<S$@(" @;&]G7W,@(" @(" @(" @X=0A=
M/2 @("!F,2QF."QF,0T*(" @("!C;7 N97$@(" @<#<L<#8@(" @(" @(" @X=0A=
M/2 @("!R,"QR," [.R -"GT-"@T*( T*#0I[(" @(" N;69I( T*(" @("!LX=0A=
M9#@@(" @(" @3$]'7T%$7T-/149&(" @/2 @("!;3$]'7T%$7T-/149&70T*X=0A=
M(" @("!N;W N9B @(" @(" @(" @(" @(" @(" @(" Y.3D-"B @(" @;F]PX=0A=
M+FD@(" @(" @(" @(" @(" @(" @(" @.3DY#0I]( T*>R @(" @+FUF:2 -X=0A=
M"B @(" @;&0X(" @(" @($Q/1U]!1%]#3TY35$%.5%,@(" @/2 @("!;3$]'X=0A=
M7T%$7T-/3E-404Y44UT-"B @(" @;F]P+F8@(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(" Y.3D-"B @(" @;F]P+FD@(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" Y.3D[.PT*?0T*#0H@#0I,3T=3D&7TQ/1S$P1E]#3TU-3TXZ#0H-"GL@X=0A=
M(" @("YM9FD@#0H@(" @(&QD9G!D(" @("!L;V=3D?8V]E9F9?<#,L;&]G7V-OX=0A=
M969F7W R(" @(" ](" @(%M,3T=3D?041?0T]%1D9=3D+#$V#0H@(" @(&9M<RYSX=0A=
M,2 @("!L;V=3D?<B @(" @(" @(" @(" @(" @(" @(" @(" ](" @(&8X+&QOX=0A=
M9U]"+&8Q#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(" @(#DY.0T*?2 -"GL@(" @("YM9F(@#0H@(" @(&QD9G!D(" @X=0A=
M("!L;V=3D?8V]E9F9?<#$L;&]G7V-O;G-T7VQO9S(@(" ](" @(%M,3T=3D?041?X=0A=
M0T].4U1!3E1372PQ-@T*(" @("!N;W N9B @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" @(" @(" Y.3D-"BAP."D@8G(N8V]N9"YS<&YT(" @3$]'X=0A=
M7TY!3E])3D9?3D5'7UI%4D\@(" @(" @.SL-"GT-"@T*( T*>R @(" @+FUFX=0A=
M:2 -"B @(" @;&1F<&0@(" @(&QO9U]T:')E<VAH;VQD+"!L;V=3D?:6YV7VQNX=0A=
M,3 @/2 @("!;3$]'7T%$7T-/3E-404Y44UTL,38-"B @(" @9FUA+G,Q(" @X=0A=
M(&QO9U]S<W$@(" @(" @(#T@(" @;&]G7W,L;&]G7W,L9C -"B @(" @;F]PX=0A=
M+FD@(" @(" @(" @(" @(" @(" @(" @.3DY.SL-"GT@#0H@#0I[(" @(" NX=0A=
M;69I( T*(" @("!G971F+F5X<" @3$]'7WA?<V5X<" @(" @/2 @("!L;V=3D?X=0A=
M>%]N;W)M#0H@(" @(&9M97)G92YS("!L;V=3D?86)S7W,@(" @(" ](" @(&8QX=0A=
M+&QO9U]S#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @(" @(" @(#DY.3L[X=0A=
M#0I]( T*( T*>R @(" @+FUF:2 -"B @(" @9V5T9BYS:6<@($Q/1U]X7VENX=0A=
M9" ](" @(&QO9U]X7VYO<FT-"B @(" @;F]P+F8@(" @(" @(" @(" @(" @X=0A=
M(#DY.0T*(" @("!N;W N:2 @(" @(" @(" @(" @(" @.3DY.SL-"GT@#0H@X=0A=
M#0I[(" @(" N;69I( T*(" @("!A;F0@(" @(" @3$]'7WA?;B @(#T@(" @X=0A=
M3$]'7WA?<V5X<"Q,3T=3D?;6%S:PT*(" @("!F;6$N<S$@(" @;&]G7W)S<2 @X=0A=
M(#T@(" @;&]G7W(L;&]G7W(L9C -"B @(" @8VUP+F=3DE(" @(' Q,"QP," @X=0A=
M(" ](" @($Q/1U]X7W-E>' L3$]'7VUA<VL[.PT*?2 -"B -"GL@(" @("YMX=0A=
M9FD@#0H@(" @('-U8B @(" @("!,3T=3D?>%]N(" @/2 @("!,3T=3D?>%]N+$Q/X=0A=
M1U]B:6%S#0H@(" @(&YO<"YF(" @(" @(" @(" @(" @(" Y.3D-"B @(" @X=0A=
M<VAL(" @(" @($Q/1U]X7VEN9" ](" @($Q/1U]X7VEN9"PQ.SL-"GT@#0H@X=0A=
M#0I[(" @(" N;69I( T*(" @("!S971F+G-I9R @;&]G7VX@(" @(#T@(" @X=0A=
M3$]'7WA?;@T*(" @("!N;W N9B @(" @(" @(" @(" @(" @.3DY#0H@(" @X=0A=
M('-H<BYU(" @("!,3T=3D?>%]I;F0@/2 @("!,3T=3D?>%]I;F0L-38[.PT*?2 -X=0A=
M"B -"GL@(" @("YM9FD@#0H@(" @(&YO<"YM(" @(" @(" @(" @(" @(" YX=0A=
M.3D-"B @(" @;F]P+F8@(" @(" @(" @(" @(" @(#DY.0T*(" @("!S:&P@X=0A=
M(" @(" @3$]'7WA?:6YD(#T@(" @3$]'7WA?:6YD+#,[.PT*?2 -"B -"GL@X=0A=
M(" @("YM9FD@#0H@(" @(&YO<"YM(" @(" @(" @(" @(" @(" @(" @(#DYX=0A=
M.0T*(" @("!F;6$N<S$@(" @;&]G7W!O;'E?<3$@(" @/2 @("!L;V=3D?<RQLX=0A=
M;V=3D?8V]E9F9?<#,L;&]G7V-O969F7W R#0H@(" @(&YO<"YI(" @(" @(" @X=0A=
M(" @(" @(" @(" @(#DY.0T*?2 -"GL@(" @("YM9FD@#0H@(" @(&YO<"YMX=0A=
M(" @(" @(" @(" @(" @(" @(" @(#DY.0T*(" @("!F;6$N<S$@(" @;&]GX=0A=
M7W!O;'E?<#$@(" @/2 @("!L;V=3D?<BQL;V=3D?8V]E9F9?<#,L;&]G7V-O969FX=0A=
M7W R#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @(" @(" @(#DY.3L[#0I]X=0A=
M#0H-"B -"GL@(" @("YM9F(@#0H@(" @(" @(" @861D(" @(" @(" @(" @X=0A=
M3$]'7T%$7T-/3E-404Y44R @(" @(" @(#T@(" @3$]'7T%$7T-/3E-404Y4X=0A=
M4RQ,3T=3D?>%]I;F0-"B @(" @(" @("!F8VUP+FQT+G,Q(" @("!P,3$L<#$RX=0A=
M(" @(" @(" @(" @(" @(" @/2 @("!L;V=3D?86)S7W,L;&]G7W1H<F5S:&AOX=0A=
M;&0-"BAP,3 I(" @("!B<BYC;VYD+G-P;G0@("!,3T=3D?3D%.7TE.1E].14=3D?X=0A=
M6D523R @(" @(" [.PT*?2 -"B -"GL@(" @("YM9FD@#0H@(" @(&QD9F0@X=0A=
M(" @("!L;V=3D?5" @(" @/2 @("!;3$]'7T%$7T-/3E-404Y44UT-"B @(" @X=0A=
M;F]P+F8@(" @(" @(" @(" @(" @(#DY.0T*(" @("!N;W N:2 @(" @(" @X=0A=
M(" @(" @(" @.3DY.SL-"GT@#0H@#0I[(" @(" N;69I( T*(" @("!N;W NX=0A=
M;2 @(" @(" @(" @(" @(" @(" @(" Y.3D-"B @(" @9FUA+G,Q(" @(&QOX=0A=
M9U]P;VQY7W$R(" @(#T@(" @;&]G7W,L;&]G7W!O;'E?<3$L;&]G7V-O969FX=0A=
M7W Q#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @(" @(" @(#DY.0T*?2 -X=0A=
M"GL@(" @("YM9FD@#0H@(" @(&YO<"YM(" @(" @(" @(" @(" @(" @(" @X=0A=
M(#DY.0T*(" @("!F;6$N<S$@(" @;&]G7W!O;'E?<#(@(" @/2 @("!L;V=3D?X=0A=
M<BQL;V=3D?<&]L>5]P,2QL;V=3D?8V]E9F9?<#$-"B @(" @;F]P+FD@(" @(" @X=0A=
M(" @(" @(" @(" @(" @.3DY.SL-"GT-"@T*( T*>R @(" @+FUF:2 -"B @X=0A=
M(" @;F]P+FT@(" @(" @(" @(" @(" @(#DY.0T*(" @("!F8W9T+GAF(" @X=0A=
M;&]G7VX@(" @(#T@(" @;&]G7VX-"B @(" @;F]P+FD@(" @(" @(" @(" @X=0A=
M(" @(#DY.3L[#0I]( T*( T*>R @(" @+FUF:2 -"B @(" @(" @("!N;W NX=0A=
M;2 @(" @(" @(" @(#DY.0T**' Q,2D@(" @(&9M82YS(" @("!F." @(#T@X=0A=
M(" @;&]G7W-S<2QL;V=3D?<&]L>5]Q,BQL;V=3D?<PT*(" @(" @(" @(&YO<"YIX=0A=
M(" @(" @(" @(" @.3DY#0I]( T*>R @(" @+FUF:2 -"B @(" @;F]P+FT@X=0A=
M(" @(" @(" @(" @(" @(" @(" @.3DY#0H@(" @(&9M82YS,2 @("!L;V=3D?X=0A=
M<&]L>5]P,R @(" ](" @(&QO9U]R<W$L;&]G7W!O;'E?<#(L;&]G7W(-"B @X=0A=
M(" @;F]P+FD@(" @(" @(" @(" @(" @(" @(" @.3DY.SL-"GT-"@T*>R @X=0A=
M(" @+FUF:2 -"B @(" @(&YO<"YM(#DY.0T**' Q,2D@9FUA+G,Q(" @(" @X=0A=
M(&QO9S$P7V8X(#T@;&]G7W-S<2QL;V=3D?<&]L>5]Q,BQL;V=3D?<PT*(" @(" @X=0A=
M;F]P+FD@.3DY#0I]#0H[.PT*#0H-"@T*( T*>R @(" @+FUF:2 -"B @(" @X=0A=
M;F]P+FT@(" @(" @(" @(" @(" @(#DY.0T*(" @("!F;6$N<S$@(" @;&]GX=0A=
M7U0@(" @(#T@(" @;&]G7VXL;&]G7V-O;G-T7VQO9S(L;&]G7U0-"B @(" @X=0A=
M;F]P+FD@(" @(" @(" @(" @(" @(#DY.3L[#0I]( T*( T*>R @(" @+FUFX=0A=
M8B -"B @(" @(" @("!N;W N;2 @(" @(" @(" @(#DY.0T**' Q,BD@(" @X=0A=
M(&9M82YS(" @("!F." @(#T@(" @;&]G7U0L9C$L;&]G7W!O;'E?<#,-"B @X=0A=
M(" @(" @("!N;W N8B Y.3D-"GT@#0H-"@T*>R @(" @+FUF8B -"B @(" @X=0A=
M(" @("!N;W N;2 Y.3D-"BAP,3(I(" @("!F;6$N<S$@(" @;&]G,3!?9C@@X=0A=
M(" ](" @(&QO9U]4+&8Q+&QO9U]P;VQY7W S#0H@(" @(" @(" @;F]P+F(@X=0A=
M.3DY#0I]#0H[.PT*#0I[(" @(" N;69B( T*(" @(" @(" @(&YO<"YM(#DYX=0A=
M.0T**' V*2 @(" @(&9M82YS(" @("!F." @(#T@(" @;&]G7VEN=3DE]L;C$PX=0A=
M+"!L;V<Q,%]F."P@9C -"B @(" @(" @("!B<BYR970N<W!T:R @("!B," @X=0A=
M( T*?0T*.SL-"@T*#0H@#0I,3T=3D?3D%.7TE.1E].14=3D?6D523SH-"@T*+R\@X=0A=
M("!,;V=3D;:6YF72 @(" @(#T@:6YF#0H-"B\O(" @3&]G6S!=3D(" @(" @(" ]X=0A=
M("UI;F9I;FET>2P@(" @(" @8V%L;"!E<G)O<B!S=3D7!P;W)T+"!T86<@- T*X=0A=
M+R\@("!,;V=3D;+3!=3D(" @(" @(#T@+6EN9FEN:71Y+" @(" @("!C86QL(&5RX=0A=
M<F]R('-U<'!O<G0L('1A9R T#0H-"B\O(" @3&]G6RUN;VYZ97)O72 ]('%NX=0A=
M86X@:6YD969I;FET92P@8V%L;"!E<G)O<B!S=3D7!P;W)T+"!T86<@-0T*+R\@X=0A=
M("!,;V=3D;+6EN9ET@(" @(#T@<6YA;B!I;F1E9FEN:71E+"!C86QL(&5R<F]RX=0A=
M('-U<'!O<G0L('1A9R U#0H-"B\O(" @3&]G6S!=3D(" @(" @(" ]("UI;F9IX=0A=
M;FET>2P@(" @(" @8V%L;"!E<G)O<B!S=3D7!P;W)T+"!T86<@,3 -"B\O(" @X=0A=
M3&]G6RTP72 @(" @(" ]("UI;F9I;FET>2P@(" @(" @8V%L;"!E<G)O<B!SX=0A=
M=3D7!P;W)T+"!T86<@,3 -"@T*+R\@("!,;V=3D;+6YO;GIE<F]=3D(#T@<6YA;B!IX=0A=
M;F1E9FEN:71E+"!C86QL(&5R<F]R('-U<'!O<G0L('1A9R Q,0T*+R\@("!,X=0A=
M;V=3D;+6EN9ET@(" @(#T@<6YA;B!I;F1E9FEN:71E+"!C86QL(&5R<F]R('-UX=0A=
M<'!O<G0L('1A9R Q,0T*#0HO+R @($QO9UM.86Y=3D(" @(" @/2!Q=3D6ET92!.X=0A=
M84X-"@T*+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\-"B\O(&EF('@@:7,@3F%NX=0A=
M+"!L96%V92!I;6UE9&EA=3D&5L>0T*(" @(" @9F-L87-S+FTN=3D6YC(" @("!PX=0A=
M."QP," @(" @(" @(" ](&8X+"! <VYA;B @?"! <6YA;@T*.SL-"BAP."D@X=0A=
M(&9N;W)M(" @(" @(" @(" @9C@@(" @(" @(" @(" @/2!F. T*.SL-"BAPX=0A=
M."D@(&)R+G)E=3D"YS<&YT(" @(" @8C -"@T*#0HO+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+PT*+R\@:68@>"!I<R K:6YF:6YI=3D'DL(&QE879E(&EM;65D:6%TX=0A=
M96QY#0H@(" @("!F8VQA<W,N;2YU;F,@(" @(' X+' P(" @(" @(" @(#T@X=0A=
M9C@L($!I;F8@('P@0'!O<PT*.SL-"BAP."D@(&9R8W!A+G,Q(" @(" @(" @X=0A=
M9C@L<#$U(" @(" @(" @/2!F,2QF, T*.SL-"BAP."D@(&)R+G)E=3D"YS<&YTX=0A=
M(" @(" @8C -"@T*#0HO+R!E;'-E(&EF('@@:7,@>F5R;RP@<V5T('1A9R!TX=0A=
M;R T("AL;V=3DF*2!O<B Q," H;&]G,3!F*2!A;F0@8V%L;"!E<G)O<B!S=3D7!PX=0A=
M;W)T#0HO+R!,;V=3D;*RTP72 ]("UI;F9I;FET>2P@=3DVET:"!D8GH@<V5T+B!2X=0A=
M86YG92!E<G)O<@T*#0H@(" @("!F8VQA<W,N;2YU;F,@(" @(' X+' Y(" @X=0A=
M(" @(" @(#T@9C@L($!Z97)O#0H[.PT**' X*2 @9G)C<&$@(" @(" @(" @X=0A=
M("!F."QP,34@(" @(" @(" ](&8Q+&8P#0H[.PT*#0HN<')E9"YR96P@(FUUX=0A=
M=3D&5X(BQP-RQP-@T**' X*2 @9FUE<F=3DE+FYS(" @(" @("!F." @(" @(" @X=0A=
M(" @(" ](&8X+&8X#0HH<#<I("!M;W8@(" @(" @(" @(" @($Q/1U]T86<@X=0A=
M(" @(" @(#T@- T**' V*2 @;6]V(" @(" @(" @(" @("!,3T=3D?=3D&%G(" @X=0A=
M(" @(" ](#$P#0H-"BAP."D@(&)R+F-O;F0N<W!N=3D" @(" @7U]L:6)M7V5RX=0A=
M<F]R7W)E9VEO;@T*#0HO+R!E;'-E(&EF('@@:7,@+6YO;BUZ97)O+"!S970@X=0A=
M=3D&%G('1O(#4@86YD(&-A;&P@97)R;W(@<W5P<&]R=3D T*+R\@3&]G6RUN;W)MX=0A=
M+" M=3D6YO<FTL("UI;F9=3D(#T@<6YA;B!I;F1E9FEN:71E+"!I;G9A;&ED('-EX=0A=
M=3D"P@9&]M86EN(&5R<F]R#0H-"BAP.2D@(&9C;&%S<RYM+G5N8R @(" @<#$PX=0A=
M+"!P," @(" @(" @(#T@9C@L($!I;F8@?"! ;F]R;2!\($!U;F]R;2!\($!NX=0A=
M96<-"CL[#0HH<#$P*2 @9G)C<&$N<S @(" @(" @(&8X+' Q-2 @(" @(" @X=0A=
M(#T@9C L9C -"BAP-RD@(&UO=3DB @(" @(" @(" @(" @3$]'7W1A9R @(" @X=0A=
M(" @/2 U#0HH<#8I("!M;W8@(" @(" @(" @(" @($Q/1U]T86<@(" @(" @X=0A=
M(#T@,3$-"@T*(" @(" @8G(N8V]N9"YS<&YT(" @("!?7VQI8FU?97)R;W)?X=0A=
M<F5G:6]N#0H-"BYE;F1P(&QO9V8-"@T*#0H-"@T*+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+PT*+R\@17)R;W(@:&%N9&QI;F<@<F5G:6]N#0HO+R\O+R\O+R\OX=0A=
M+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+R\O+R\O#0H-"@T*#0HO+R!3=3D&%C:R!O<&5R871I;VYS('=3DH96X@X=0A=
M8V%L;&EN9R!E<G)O<B!S=3D7!P;W)T+@T*+R\@(" @(" @*#$I(" @(" @(" @X=0A=
M(" @(" @(" @("@R*0T*+R\@("!S<" @("T^("L@(" @(" @(" @(" @(" @X=0A=
M('!S<" M/B K#0HO+R @(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @('P-"B\O(" @(" @(" @("!\(" @(" @(" @(" @(" @(" @(" @(" @X=0A=
M?" \+2!'4E]9#0HO+R @(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @('P-"B\O(" @(" @(" @("!\(#PM1U)?62 @(" @(" @(" @("!9,BT^X=0A=
M? T*+R\@(" @(" @(" @('P@(" @(" @(" @(" @(" @(" @(" @("!\#0HOX=0A=
M+R @(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @('P@/"T@1U)?X=0A=
M6 T*+R\@(" @(" @(" @('P@(" @(" @(" @(" @(" @(" @(" @("!\#0HOX=0A=
M+R @<W M-C0@+3X@*R @(" @(" @(" @(" @(" @<W @+3X@("L-"B\O(" @X=0A=
M('-A=3DF4@87(N<&9S(" @(" @(" @(" @(" @("!S879E(&(P#0HO+R @("!SX=0A=
M879E(&=3DP#0H-"@T*#0HO+R @(" @("@S*2 H8V%L;"D@(" @(" @(" @(" @X=0A=
M("@T*0T*+R\@("!P<W @+3X@*R @(" @(" @(" @(" @(" @("!S<" M/B KX=0A=
M#0HO+R @(" @(" @("!\(" @(" @(" @(" @(" @(" @(" @(" @('P-"B\OX=0A=
M(" @("!2,R M/GP@/"T@1U)?4D5354Q4(" @(" @(" @(" @?" M/B!F. T*X=0A=
M+R\@(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @("!\#0HO+R @X=0A=
M(" @63(@+3Y\(#PM($=3D27UD@(" @(" @(" @(" @(" @('P-"B\O(" @(" @X=0A=
M(" @('P@(" @(" @(" @(" @(" @(" @(" @(" @? T*+R\@(" @(%@Q("T^X=0A=
M?" @(" @(" @(" @(" @(" @(" @(" @("!\#0HO+R @(" @(" @("!\(" @X=0A=
M(" @(" @(" @(" @(" @(" @(" @('P-"B\O(" @<W @+3X@("L@(" @(" @X=0A=
M(" @(" @(" @(" @(" @(" @*PT*+R\@(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(" @("!R97-T;W)E(&=3DP#0HO+R @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" @(')E<W1O<F4@87(N<&9S#0H-"BYP<F]C(%]?;&EB;5]EX=0A=
M<G)O<E]R96=3DI;VX-"E]?;&EB;5]E<G)O<E]R96=3DI;VXZ#0HN<')O;&]G=3D64-X=0A=
M"@T*+R\@*#$I#0I[("YM9FD-"B @(" @(" @861D(" @1U)?4&%R86UE=3D&5RX=0A=
M7UD]+3,R+'-P(" @(" @(" @(" @("\O(%!A<F%M971E<B R('9A;'5E#0H@X=0A=
M(" @(" @(&YO<"YF(# -"BYS879E(" @87(N<&9S+$=3D27U-!5D5?4$93#0H@X=0A=
M(" @(" @(&UO=3DB @1U)?4T%615]01E,]87(N<&9S(" @(" @(" @(" @(" @X=0A=
M(" O+R!3879E(&%R+G!F<PT*?0T*>R N;69I#0HN9F9R86UE(#8T#0H@(" @X=0A=
M(" @(&%D9"!S<#TM-C0L<W @(" @(" @(" @(" @(" @(" @(" @(" @(" OX=0A=
M+R!#<F5A=3D&4@;F5W('-T86-K#0H@(" @(" @(&YO<"YF(# -"B @(" @(" @X=0A=
M;6]V($=3D27U-!5D5?1U ]9W @(" @(" @(" @(" @(" @(" @(" @("\O(%-AX=0A=
M=3DF4@9W -"GT[.PT*#0H-"B\O("@R*0T*>R N;6UI#0H@(" @(" @('-T9G,@X=0A=
M6T=3D27U!A<F%M971E<E]972 ](&8Q+#$V(" @(" @(" @("\O(%-43U)%(%!AX=0A=
M<F%M971E<B R(&]N('-T86-K#0H@(" @(" @(&%D9"!'4E]087)A;65T97)?X=0A=
M6" ](#$V+'-P(" @(" @(" @(" @("\O(%!A<F%M971E<B Q(&%D9')E<W,-X=0A=
M"BYS879E(" @8C L($=3D27U-!5D5?0C -"B @(" @(" @;6]V($=3D27U-!5D5?X=0A=
M0C ]8C @(" @(" @(" @(" @(" @(" @(" @+R\@4V%V92!B, T*?3L[#0H-X=0A=
M"BYB;V1Y#0HO+R H,RD-"GL@+FUI8@T*(" @(" @("!S=3D&9S(%M'4E]087)AX=0A=
M;65T97)?6%T@/2!L;V=3D?>%]N;W)M(" @(" @(" @(" O+R!35$]212!087)AX=0A=
M;65T97(@,2!O;B!S=3D&%C:PT*(" @(" @("!A9&0@("!'4E]087)A;65T97)?X=0A=
M4D5354Q4(#T@,"Q'4E]087)A;65T97)?62 @+R\@4&%R86UE=3D&5R(#,@861DX=0A=
M<F5S<PT*(" @(" @("!N;W N8B P#0I]#0I[("YM:6(-"B @(" @(" @<W1FX=0A=
M<R!;1U)?4&%R86UE=3D&5R7UE=3D(#T@9C@@(" @(" @(" @(" @(" @(" @("\OX=0A=
M(%-43U)%(%!A<F%M971E<B S(&]N('-T86-K#0H@(" @(" @(&%D9" @($=3D2X=0A=
M7U!A<F%M971E<E]9(#T@+3$V+$=3D27U!A<F%M971E<E]9#0H@(" @(" @(&)RX=0A=
M+F-A;&PN<W!T:R!B,#U?7VQI8FU?97)R;W)?<W5P<&]R=3D" @(" @(" @("\OX=0A=
M($-A;&P@97)R;W(@:&%N9&QI;F<@9G5N8W1I;VX-"GT[.PT*#0H-"GL@+FUMX=0A=
M:0T*(" @(" @("!L9&9S("!F." ](%M'4E]087)A;65T97)?4D5354Q472 @X=0A=
M(" @(" O+R!'970@<F5T=3D7)N(')E<W5L=3D"!O9F8@<W1A8VL-"BYR97-T;W)EX=0A=
M#0H@(" @(" @(&%D9" @('-P(#T@-C0L<W @(" @(" @(" @(" @(" @(" @X=0A=
M(" @("\O(%)E<W1O<F4@<W1A8VL@<&]I;G1E<@T*(" @(" @("!M;W8@("!BX=0A=
M," ]($=3D27U-!5D5?0C @(" @(" @(" @(" @(" @(" O+R!297-T;W)E(')EX=0A=
M=3D'5R;B!A9&1R97-S#0I].SL-"@T*>R N;6EB#0H@(" @(" @(&UO=3DB @(&=3DPX=0A=
M(#T@1U)?4T%615]'4" @(" @(" @(" @(" @(" @("\O(%)E<W1O<F4@9W -X=0A=
M"B @(" @(" @;6]V(" @87(N<&9S(#T@1U)?4T%615]01E,@(" @(" @(" @X=0A=
M(" @+R\@4F5S=3D&]R92!A<BYP9G,-"B @(" @(" @8G(N<F5T+G-P=3D&L@(" @X=0A=
M(&(P(" @(" @(" @(" @(" @(" @(" @+R\@4F5T=3D7)N#0I].SL-"@T*+F5NX=0A=
M9' @7U]L:6)M7V5R<F]R7W)E9VEO;@T*#0H-"BYT>7!E(" @7U]L:6)M7V5RX=0A=
M<F]R7W-U<'!O<G0L0&9U;F-T:6]N#0HN9VQO8F%L(%]?;&EB;5]E<G)O<E]SX=0A=
(=3D7!P;W)T#0IO                                                X=0A=
                                                             X=0A=
end=0A=
@eof=0A=
=0A=
chmod 600 logf_bad.s=0A=
=0A=
echo x - logf_ok.s '[non-ascii]'=0A=
$unpacker <<'@eof'=0A=
begin 600 logf_ok.s=0A=
M+F9I;&4@(FQO9V8N<R(-"@T*#0HO+R!#;W!Y<FEG:'0@*&,I(#(P,# L($ENX=0A=
M=3D&5L($-O<G!O<F%T:6]N#0HO+R!!;&P@<FEG:'1S(')E<V5R=3DF5D+@T*+R\-X=0A=
M"B\O($-O;G1R:6)U=3D&5D(#(O,B\R,# P(&)Y($IO:&X@2&%R<FES;VXL(%1EX=0A=
M9"!+=3D6)A<VMA+"!";V(@3F]R:6XL(%-H86YE(%-T;W)Y+ T*+R\@86YD(%!IX=0A=
M;F<@5&%K(%!E=3D&5R(%1A;F<@;V8@=3D&AE($-O;7!U=3D&%T:6]N86P@4V]F=3D'=3DAX=
=0A=
M<F4@3&%B+"!);G1E;"!#;W)P;W)A=3D&EO;BX-"B\O#0HO+R!705)204Y462!$X=0A=
M25-#3$%)3452#0HO+PT*+R\@5$A)4R!33T945T%212!)4R!04D]6241%1"!"X=0A=
M62!42$4@0T]065))1TA4($A/3$1%4E,@04Y$($-/3E1224)55$]24PT*+R\@X=0A=
M(D%3($E3(B!!3D0@04Y9($584%)%4U,@3U(@24U03$E%1"!705)204Y42453X=0A=
M+"!)3D-,541)3D<L($)55"!.3U0-"B\O($Q)34E4140@5$\L(%1(12!)35!,X=0A=
M245$(%=3D!4E)!3E1)15,@3T8@34520TA!3E1!0DE,2519($%.1"!&251.15-3X=0A=
M($9/4@T*+R\@02!005)424-53$%2(%!54E!/4T4@05)%($1)4T-,04E-140NX=0A=
M($E.($Y/($5614Y4(%-(04Q,($E.5$5,($]2($E44PT*+R\@0T].5%))0E54X=0A=
M3U)3($)%($Q)04),12!&3U(@04Y9($1)4D5#5"P@24Y$25)%0U0L($E.0TE$X=0A=
M14Y404PL(%-014-)04PL#0HO+R!%6$5-4$Q!4EDL($]2($-/3E-%455%3E1)X=0A=
M04P@1$%-04=3D%4R H24Y#3%5$24Y'+"!"550@3D]4($Q)34E4140@5$\L#0HOX=0A=
M+R!04D]#55)%345.5"!/1B!354)35$E4551%($=3D/3T13($]2(%-%4E9)0T53X=0A=
M.R!,3U-3($]&(%5312P@1$%402P@3U(-"B\O(%!23T9)5%,[($]2($)54TE.X=0A=
M15-3($E.5$524E505$E/3BD@2$]7159%4B!#0553140@04Y$($].($%.62!4X=0A=
M2$5/4ED-"B\O($]&($Q)04))3$E462P@5TA%5$A%4B!)3B!#3TY44D%#5"P@X=0A=
M4U1224-4($Q)04))3$E462!/4B!43U)4("A)3D-,541)3D<-"B\O($Y%1TQ)X=0A=
M1T5.0T4@3U(@3U1(15)725-%*2!!4DE324Y'($E.($%.62!705D@3U54($]&X=0A=
M(%1(12!54T4@3T8@5$A)4PT*+R\@4T]&5%=3D!4D4L($5614X@248@041625-%X=0A=
M1"!/1B!42$4@4$]34TE"24Q)5%D@3T8@4U5#2"!$04U!1T4N#0HO+PT*+R\@X=0A=
M26YT96P@0V]R<&]R871I;VX@:7,@=3D&AE(&%U=3D&AO<B!O9B!T:&ES(&-O9&4LX=0A=
M(&%N9"!R97%U97-T<R!T:&%T(&%L; T*+R\@<')O8FQE;2!R97!O<G1S(&]RX=0A=
M(&-H86YG92!R97%U97-T<R!B92!S=3D6)M:71T960@=3D&\@:70@9&ER96-T;'D@X=0A=
M870-"B\O(&AT=3D' Z+R]D979E;&]P97(N:6YT96PN8V]M+V]P96YS;W5R8V4NX=0A=
M#0H@#0HO+PT*+R\@07-S96UB;'D@;6%C<F]S#0HO+ST]/3T]/3T]/3T]/3T]X=0A=
M/3T]/3T]/3T]/3T]/3T]/3T]/3T]/3T]/3T]#0H-"B\O(&EN=3D&5G97(@<F5GX=0A=
M:7-T97)S('5S960-"@T*($Q/1U]!1%]#3T5&1B @(" @(" @(" @(" @(#T@X=0A=
M<C,S#0H@3$]'7T%$7T-/3E-404Y44R @(" @(" @(" @/2!R,S0-"B!,3T=3D?X=0A=
M;6%S:R @(" @(" @(" @(" @(" @(" ]('(S-0T*#0H@3$]'7T9&1C<@(" @X=0A=
M(" @(" @(" @(" @(" @/2!R,S8-"B!,3T=3D?8FEA<R @(" @(" @(" @(" @X=0A=
M(" @(" ]('(S-PT*($Q/1U]X7VX@(" @(" @(" @(" @(" @(" @(#T@<C,XX=0A=
M#0H@3$]'7WA?:6YD(" @(" @(" @(" @(" @(" @/2!R,SD-"B!,3T=3D?>%]SX=0A=
M97AP(" @(" @(" @(" @(" @(" ]('(T, T*#0H@1U)?4T%615]"," @(" @X=0A=
M(" @(" @(" @(" @/2!R-#$-"B!'4E]3059%7U!&4R @(" @(" @(" @(" @X=0A=
M(" ]('(T,@T*($=3D27U-!5D5?1U @(" @(" @(" @(" @(" @(#T@<C0S#0H-X=0A=
M"B!'4E]087)A;65T97)?6" @(" @(" @(" @(" @(" ]('(T- T*($=3D27U!AX=0A=
M<F%M971E<E]9(" @(" @(" @(" @(" @(#T@<C0U#0H@1U)?4&%R86UE=3D&5RX=0A=
M7U)%4U5,5" @(" @(" @(" @/2!R-#8-"B!,3T=3D?=3D&%G(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" ]('(T-PT*#0H-"@T*#0H-"B\O(&9L;V%T:6YG('!O:6YTX=0A=
M(')E9VES=3D&5R<R!U<V5D#0H-"B!L;V=3D?8V]E9F9?<#,@(" @(" @(" @(" @X=0A=
M(" @/2!F,S(-"B!L;V=3D?8V]E9F9?<#(@(" @(" @(" @(" @(" @/2!F,S,-X=0A=
M"B!L;V=3D?8V]E9F9?<#$@(" @(" @(" @(" @(" @/2!F,S0-"B!L;V=3D?8V]NX=0A=
M<W1?;&]G,B @(" @(" @(" @(" @/2!F,S4-"@T*(&QO9U]T:')E<VAH;VQDX=0A=
M(" @(" @(" @(" @(" ](&8S-@T*(&QO9U]"(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" ](&8S-PT*(&QO9U]R(" @(" @(" @(" @(" @(" @(" @(" ](&8SX=0A=
M. T*(&QO9U]P;VQY7W Q(" @(" @(" @(" @(" @(" ](&8S.0T*(&QO9U]RX=0A=
M<W$@(" @(" @(" @(" @(" @(" @(" ](&8T, T*#0H@;&]G7W!O;'E?<#(@X=0A=
M(" @(" @(" @(" @(" @(#T@9C0Q#0H@;&]G7W!O;'E?<#,@(" @(" @(" @X=0A=
M(" @(" @(#T@9C0R#0H@;&]G7VX@(" @(" @(" @(" @(" @(" @(" @(#T@X=0A=
M9C0S#0H@;&]G7U0@(" @(" @(" @(" @(" @(" @(" @(#T@9C0T#0H@;&]GX=0A=
M7W,@(" @(" @(" @(" @(" @(" @(" @(#T@9C0U#0H-"B!L;V=3D?<&]L>5]QX=0A=
M,2 @(" @(" @(" @(" @(" @/2!F-#8-"B!L;V=3D?<W-Q(" @(" @(" @(" @X=0A=
M(" @(" @(" @/2!F-#<-"B!L;V=3D?86)S7W,@(" @(" @(" @(" @(" @(" @X=0A=
M/2!F-#@-"B!L;V=3D?<&]L>5]Q,B @(" @(" @(" @(" @(" @/2!F-#D-"B!LX=0A=
M;V=3D?>%]N;W)M(" @(" @(" @(" @(" @(" @/2!F-3 -"@T*(&QO9U]I;G9?X=0A=
M;&XQ," @(" @(" @(" @(" @(" ](&8U,0T*(&QO9S$P7V8X(" @(" @(" @X=0A=
M(" @(" @(" @(" ](&8U,@T*#0HN9&%T80T*#0HN86QI9VX@,38-"@T*#0ILX=0A=
M;V=3D?8V]E9F9?=3D&%B;&4Z#0ID871A." P>&)F9# P,#$P,#AF,SED-3D@(" @X=0A=
M("\O(' S#0ID871A." P>#-F9#4U-38P-S-E,&,T-6$@(" @("\O(' R#0H-X=0A=
M"FQO9U]C;VYS=3D&%N=3D'-?=3D&%B;&4Z#0ID871A." P>&)F9&9F9F9F9F9F865AX=0A=
M,34@(" @+R\@<#$-"F1A=3D&$X(#!X,V9E-C)E-#)F969A,SEE9B @(" O+R!,X=0A=
M;V<H,BD-"F1A=3D&$X(#!X,V8W,# P,# P,# P,# P," @(" O+R R7BTX+"!TX=0A=
M:')E<VAH;VQD#0ID871A." P>#-F9&)C8C=3DB,34R-F4U,&4@(" @+R\@,2]LX=0A=
M;C$P#0H-"F1A=3D&$X(#!X,T8V,# T,#$U-40U.#@Y12 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" @,"\R-38I#0ID871A." P>#-&-S@Q,C$R,30U.#9"-30@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @(#$O,C4V*0T*9&%T83@@,'@S1C@T,3DR.48YX=0A=
M-C@S,D8P(" @("\O;&]G*#$O9G)C<&$H,2L@(" R+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T8X0S,Q-S,X-$,W-48P-B @(" O+VQO9R@Q+V9R8W!A*#$K(" @,R\R-38IX=0A=
M#0ID871A." P>#-&.3%!-D(Y,4%#-S,S.#8@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @(#0O,C4V*0T*9&%T83@@,'@S1CDU0D$Y035$.4%#,#,Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(" U+S(U-BD-"F1A=3D&$X(#!X,T8Y.40R03@P-S0S,C5&X=0A=
M-" @(" O+VQO9R@Q+V9R8W!A*#$K(" @-B\R-38I#0ID871A." P>#-&.40VX=0A=
M0C(W,C4Y-SDX,#(@(" @+R]L;V<H,2]F<F-P82@Q*R @(#<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D$P0S4X1D$Q.41&04%!(" @("\O;&]G*#$O9G)C<&$H,2L@(" XX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9!,CDU-$,W.$-"0T4Q0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" @.2\R-38I#0ID871A." P>#-&031!.31$,D1!.39#-38@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,3 O,C4V*0T*9&%T83@@,'@S1D$V-T,Y-$8RX=0A=
M1#1"0C4X(" @("\O;&]G*#$O9G)C<&$H,2L@(#$Q+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9!.#4Q.#A"-C,P1C V." @(" O+VQO9R@Q+V9R8W!A*#$K(" Q,B\R-38IX=0A=
M#0ID871A." P>#-&04$V0CA!0D4W,T%&-$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,3,O,C4V*0T*9&%T83@@,'@S1D%#-#0Q13 V1C<R03E%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#$T+S(U-BD-"F1A=3D&$X(#!X,T9!13%%-C<Q,S8P-D0PX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(" Q-2\R-38I#0ID871A." P>#-&049&X=0A=
M038Y,3%!0CDS,#$@(" @+R]L;V<H,2]F<F-P82@Q*R @,38O,C4V*0T*9&%TX=0A=
M83@@,'@S1D(P14,Q,SE#-41!-C Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#$WX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9",41"1#(V-#-$,3DP0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Q."\R-38I#0ID871A." P>#-&0C)#0S<R.#1&135&,4,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,3DO,C4V*0T*9&%T83@@,'@S1D(S0D1&-4$WX=0A=
M1#%%138T(" @("\O;&]G*#$O9G)C<&$H,2L@(#(P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9"-$(P-40W04$P,3)%," @(" O+VQO9R@Q+V9R8W!A*#$K(" R,2\R-38IX=0A=
M#0ID871A." P>#-&0C4X,$1"-T-%0C4W,#(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,C(O,C4V*0T*9&%T83@@,'@S1D(V-S1&,#@Y,S8U03=3D!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#(S+S(U-BD-"F1A=3D&$X(#!X,T9"-S8Y148R0S9"-38XX=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(" R-"\R-38I#0ID871A." P>#-&0C@UX=0A=
M1D0Y,C<U,#9!-#@@(" @+R]L;V<H,2]F<F-P82@Q*R @,C4O,C4V*0T*9&%TX=0A=
M83@@,'@S1D(Y,S,U135$-3DT.3@Y(" @("\O;&]G*#$O9G)C<&$H,2L@(#(VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9"03)",#(R,$,X135&-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" R-R\R-38I#0ID871A." P>#-&0D(P,# T04,Q03@V04,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,C@O,C4V*0T*9&%T83@@,'@S1D)"1CDV.#<VX=0A=
M.49#03$Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#(Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9"0T-&141"1D5%,3-!." @(" O+VQO9R@Q+V9R8W!A*#$K(" S,"\R-38IX=0A=
M#0ID871A." P>#-&0D1!-S(W-C,X-#0V03(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @,S$O,C4V*0T*9&%T83@@,'@S1D)%03,R-3=3D&13$P1C=3D!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#,R+S(U-BD-"F1A=3D&$X(#!X,T9"1C=3D"13E&141"1D1%X=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(" S,R\R-38I#0ID871A." P>#-&0S RX=0A=
M04(S-3)&1C(U1C0@(" @+R]L;V<H,2]F<F-P82@Q*R @,S0O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,P.3=3D#134W.40R,#1$(" @("\O;&]G*#$O9G)C<&$H,2L@(#,UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#,3$W.$4X,C(W130W0R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" S-B\R-38I#0ID871A." P>#-&0S$X-3<T-T1"14-&,S0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @,S<O,C4V*0T*9&%T83@@,'@S1D,Q1C-".3(UX=0A=
M1C(U1#0Q(" @("\O;&]G*#$O9G)C<&$H,2L@(#,X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#,C8R-40Q139$1$8U-R @(" O+VQO9R@Q+V9R8W!A*#$K(" S.2\R-38IX=0A=
M#0ID871A." P>#-&0S)$,38Q,$,X-C@Q,T$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-# O,C4V*0T*9&%T83@@,'@S1D,S-#!#-3DW-#$Q-#)%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#0Q+S(U-BD-"F1A=3D&$X(#!X,T9#,T(P.$(V-S4W1C)!X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(" T,B\R-38I#0ID871A." P>#-&0S0PX=0A=
M1$9",#@S-S@P,#,@(" @+R]L;V<H,2]F<F-P82@Q*R @-#,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,T-T4W-$4X0T$U1C=3D#(" @("\O;&]G*#$O9G)C<&$H,2L@(#0TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#-$5&-3%&-C0V-D1%-" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" T-2\R-38I#0ID871A." P>#-&0S4V,#DR13 R0D$U,38@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-#8O,C4V*0T*9&%T83@@,'@S1D,U1#(S.#4WX=0A=
M0T0W-$0U(" @("\O;&]G*#$O9G)C<&$H,2L@(#0W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#-C,Q,T$S-S,S-40W-B @(" O+VQO9R@Q+V9R8W!A*#$K(" T."\R-38IX=0A=
M#0ID871A." P>#-&0S9!,SDY1$%"0D0S.#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-#DO,C4V*0T*9&%T83@@,'@S1D,W,#,S-T1$,T-%-#%"(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#4P+S(U-BD-"F1A=3D&$X(#!X,T9#-S<V-30Q,CA&-C$RX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(" U,2\R-38I#0ID871A." P>#-&0S=3D%X=0A=
M.40X,D$P0C R,D0@(" @+R]L;V<H,2]F<F-P82@Q*R @-3(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D,X-$$V0C<U.48U,3)&(" @("\O;&]G*#$O9G)C<&$H,2L@(#4SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#.$%"-#=3D$-48U03,Q," @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" U-"\R-38I#0ID871A." P>#-&0SDQ1D4T.3 Y-C4X,4(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-34O,C4V*0T*9&%T83@@,'@S1D,Y.#$V,S0PX=0A=
M,3%!03<U(" @("\O;&]G*#$O9G)C<&$H,2L@(#4V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#.48V0S0P-S X.38V-" @(" O+VQO9R@Q+V9R8W!A*#$K(" U-R\R-38IX=0A=
M#0ID871A." P>#-&0T$U.$4W,CDS-#A&-#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-3@O,C4V*0T*9&%T83@@,'@S1D-!0D(U-4,S,38Y,T%$(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#4Y+S(U-BD-"F1A=3D&$X(#!X,T9#0C%%,3 T.3$Y149$X=0A=
M," @(" O+VQO9R@Q+V9R8W!A*#$K(" V,"\R-38I#0ID871A." P>#-&0T(YX=0A=
M-$5%.3-%,S8W0T(@(" @+R]L;V<H,2]F<F-P82@Q*R @-C$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D-"1C@U,4,P-C<U-35&(" @("\O;&]G*#$O9G)C<&$H,2L@(#8RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#0S5#,#(U-$)&,C-!-B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" V,R\R-38I#0ID871A." P>#-&0T-#,# P0SE$0C-#-3(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-C0O,C4V*0T*9&%T83@@,'@S1D-$,C0T1#DYX=0A=
M0S@U-C<T(" @("\O;&]G*#$O9G)C<&$H,2L@(#8U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9#1#@X13DS1D(R1C0U," @(" O+VQO9R@Q+V9R8W!A*#$K(" V-B\R-38IX=0A=
M#0ID871A." P>#-&0T1%1$0T,S=3D%045&,#$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-C<O,C4V*0T*9&%T83@@,'@S1D-%-3,P149&13<Q,#$R(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#8X+S(U-BD-"F1A=3D&$X(#!X,T9#14(X.4$Q-C0X0CDWX=0A=
M,2 @(" O+VQO9R@Q+V9R8W!A*#$K(" V.2\R-38I#0ID871A." P>#-&0T8QX=0A=
M13<U1D%$1CE"1$4@(" @+R]L;V<H,2]F<F-P82@Q*R @-S O,C4V*0T*9&%TX=0A=
M83@@,'@S1D-&.#1!,S)%040W0S,U(" @("\O;&]G*#$O9G)C<&$H,2L@(#<QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9#1D5",C(S,T5!,#=3D#1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" W,B\R-38I#0ID871A." P>#-&1# R.$8Y0S<P,S5#,4,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @-S,O,C4V*0T*9&%T83@@,'@S1D0P-4,X0D4PX=0A=
M1#DV,S5!(" @("\O;&]G*#$O9G)C<&$H,2L@(#<T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,#@U14(X1CA!13<Y-R @(" O+VQO9R@Q+V9R8W!A*#$K(" W-2\R-38IX=0A=
M#0ID871A." P>#-&1#!".4,X13,R1#$Y,3$@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @-S8O,C4V*0T*9&%T83@@,'@S1D0P141$,#8P0C<X,#@Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#<W+S(U-BD-"F1A=3D&$X(#!X,T9$,3(R,#(T0T8P,#8SX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(" W."\R-38I#0ID871A." P>#-&1#$TX=0A=
M0D4R.3(W045#1#0@(" @+R]L;V<H,2]F<F-P82@Q*R @-SDO,C4V*0T*9&%TX=0A=
M83@@,'@S1D0Q.# V,3A%1C$X041&(" @("\O;&]G*#$O9G)C<&$H,2L@(#@PX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$,4(U,$)"13)&0S8S0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" X,2\R-38I#0ID871A." P>#-&1#%$1C1#0S=3D#1C(T,D0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @.#(O,C4V*0T*9&%T83@@,'@S1D0R,30T-39$X=0A=
M,$5".$0T(" @("\O;&]G*#$O9G)C<&$H,2L@(#@S+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,C-%0S4Y.3%%0D$T.2 @(" O+VQO9R@Q+V9R8W!A*#$K(" X-"\R-38IX=0A=
M#0ID871A." P>#-&1#(W-#!$.48X-S!!1D(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @.#4O,C4V*0T*9&%T83@@,'@S1D0R.45#1$%"0T1&03 T(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#@V+S(U-BD-"F1A=3D&$X(#!X,T9$,D0T-C8P,D%$0T-%X=0A=
M12 @(" O+VQO9R@Q+V9R8W!A*#$K(" X-R\R-38I#0ID871A." P>#-&1#)&X=0A=
M1C8V0C T14$Y1#0@(" @+R]L;V<H,2]F<F-P82@Q*R @.#@O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0S,S4U,#1",S4U03,W(" @("\O;&]G*#$O9G)C<&$H,2L@(#@YX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$,S8P.3(U14,T-$8U1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Y,"\R-38I#0ID871A." P>#-&1#,X0D8Q0S,S,S=3D%-S4@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R @.3$O,C4V*0T*9&%T83@@,'@S1D0S0S(U,C<WX=0A=
M,S,S,3@T(" @("\O;&]G*#$O9G)C<&$H,2L@(#DR+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$,T5$1C0V,T,Q-C@S12 @(" O+VQO9R@Q+V9R8W!A*#$K(" Y,R\R-38IX=0A=
M#0ID871A." P>#-&1#0Q.4(T,C-$-44X0S<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R @.30O,C4V*0T*9&%T83@@,'@S1D0T-#4Y,44P-3,Y1C0Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@(#DU+S(U-BD-"F1A=3D&$X(#!X,T9$-#=3D#.3$W-4(V1C!!X=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(" Y-B\R-38I#0ID871A." P>#-&1#1!X=0A=
M.$(S-#$U-3)",#D@(" @+R]L;V<H,2]F<F-P82@Q*R @.3<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0T1#1&,SDP.#DP,4$P(" @("\O;&]G*#$O9G)C<&$H,2L@(#DXX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$-3 Q-3(X1$$Q1CDV." @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(" Y.2\R-38I#0ID871A." P>#-&1#4R1$0P-C,T-T0T1C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,# O,C4V*0T*9&%T83@@,'@S1D0U-4$V1#-#X=0A=
M-T(X03A!(" @("\O;&]G*#$O9G)C<&$H,2L@,3 Q+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$-3DR-40R0C$Q,D$U.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$P,B\R-38IX=0A=
M#0ID871A." P>#-&1#5"1C0P-D(U-#-$0C(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,#,O,C4V*0T*9&%T83@@,'@S1D0U14,T,S-$-4,S-4%%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3 T+S(U-BD-"F1A=3D&$X(#!X,T9$-C$Y-C5#1$(P,D,QX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$P-2\R-38I#0ID871A." P>#-&1#8TX=0A=
M-D$X-#DS-4(R03(@(" @+R]L;V<H,2]F<F-P82@Q*R Q,#8O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0V-S0P041$,S%$13DT(" @("\O;&]G*#$O9G)C<&$H,2L@,3 WX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$-D$Q.$1"-S1!-3A#-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$P."\R-38I#0ID871A." P>#-&1#9#1C,Q,#4X-C<P14,@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,#DO,C4V*0T*9&%T83@@,'@S1D0V1C$X,$4XX=0A=
M-3)&,$)!(" @("\O;&]G*#$O9G)C<&$H,2L@,3$P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$-S%&-40W,4(X.31&," @(" O+VQO9R@Q+V9R8W!A*#$K(#$Q,2\R-38IX=0A=
M#0ID871A." P>#-&1#<T1#5!149$-C9$-4,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,3(O,C4V*0T*9&%T83@@,'@S1D0W-T(W.3DR,D)$,S=3D%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3$S+S(U-BD-"F1A=3D&$X(#!X,T9$-T$Y0CDX.#E&,3E%X=0A=
M,B @(" O+VQO9R@Q+V9R8W!A*#$K(#$Q-"\R-38I#0ID871A." P>#-&1#=3D$X=0A=
M.#%",#,W14(V038@(" @+R]L;V<H,2]F<F-P82@Q*R Q,34O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0X,#8Y13,S.#(W,C,Q(" @("\O;&]G*#$O9G)C<&$H,2L@,3$VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$.#(Y.39$,T5&.$)#0B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$Q-R\R-38I#0ID871A." P>#-&1#@U.#4U-S<V1$-"1D(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,3@O,C4V*0T*9&%T83@@,'@S1D0X.#<S-C4XX=0A=
M,S(W0T-&(" @("\O;&]G*#$O9G)C<&$H,2L@,3$Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$.$%!-S4Y-S-!0CA#1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$R,"\R-38IX=0A=
M#0ID871A." P>#-&1#A$.3DR1$,X.#(T134@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,C$O,C4V*0T*9&%T83@@,'@S1D0Y,#A$,D5!-T0Y-3$R(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3(R+S(U-BD-"F1A=3D&$X(#!X,T9$.3)#-3E%-SE#,$4UX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$R,R\R-38I#0ID871A." P>#-&1#DUX=0A=
M0D0W-3!%13-%1#,@(" @+R]L;V<H,2]F<F-P82@Q*R Q,C0O,C4V*0T*9&%TX=0A=
M83@@,'@S1D0Y.$(W.#$Q03-%135"(" @("\O;&]G*#$O9G)C<&$H,2L@,3(UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$.4%&-#=3D&,S-$-# V0R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$R-B\R-38I#0ID871A." P>#-&1#E$1C(W,$,Q.3$T03@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,C<O,C4V*0T*9&%T83@@,'@S1D1!,#,R-45$X=0A=
M,31&1$$T(" @("\O;&]G*#$O9G)C<&$H,2L@,3(X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$03,S-#0P,C(T1D$W.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$R.2\R-38IX=0A=
M#0ID871A." P>#-&1$$U-S<R-44X,$,S.#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,S O,C4V*0T*9&%T83@@,'@S1D1!.#=3D$,#$V-41$,3DY(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3,Q+S(U-BD-"F1A=3D&$X(#!X,T9$04%#,D4V0S S1C@YX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$S,B\R-38I#0ID871A." P>#-&1$%$X=0A=
M0T-#-D9$1C9!.#$@(" @+R]L;V<H,2]F<F-P82@Q*R Q,S,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1",#$U0C-%0C%%-SDP(" @("\O;&]G*#$O9G)C<&$H,2L@,3,TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$0C,R,T$S038S-3DT." @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$S-2\R-38I#0ID871A." P>#-&1$(U-D9!,#0T-C(Y,#D@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q,S8O,C4V*0T*9&%T83@@,'@S1D1".#@Q04$VX=0A=
M-3E"0SDS(" @("\O;&]G*#$O9G)C<&$H,2L@,3,W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$0D%$,$)%1C-$0C$V-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$S."\R-38IX=0A=
M#0ID871A." P>#-&1$)$,C$R.3<W.#%#,D8@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q,SDO,C4V*0T*9&%T83@@,'@S1D1#,#,Y,C,V1C X.#$Y(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,30P+S(U-BD-"F1A=3D&$X(#!X,T9$0S(X0T(Q131$,S)&X=0A=
M1" @(" O+VQO9R@Q+V9R8W!A*#$K(#$T,2\R-38I#0ID871A." P>#-&1$,TX=0A=
M13$Y0C@T-S(S0S(@(" @+R]L;V<H,2]F<F-P82@Q*R Q-#(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1#-T9&.4,W-#4U-$,Y(" @("\O;&]G*#$O9G)C<&$H,2L@,30SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$0T$U-T(V-$4Y1$(P-2 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$T-"\R-38I#0ID871A." P>#-&1$-#0C$S,$$U0T5"0C @(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-#4O,C4V*0T*9&%T83@@,'@S1D1#1C!#,$0QX=0A=
M.$8S,C9&(" @("\O;&]G*#$O9G)C<&$H,2L@,30V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$1#(S,C W-4(U03(P,2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$T-R\R-38IX=0A=
M#0ID871A." P>#-&1$0T.3 R-#9$149!-D(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-#@O,C4V*0T*9&%T83@@,'@S1D1$-D5&03DQ.$0R-4-$(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,30Y+S(U-BD-"F1A=3D&$X(#!X,T9$1#DU,#DW,#=3D!134RX=0A=
M1B @(" O+VQO9R@Q+V9R8W!A*#$K(#$U,"\R-38I#0ID871A." P>#-&1$1"X=0A=
M0C)%1D4Y,D,U-30@(" @+R]L;V<H,2]F<F-P82@Q*R Q-3$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1$144R1C,T-#5%-$%&(" @("\O;&]G*#$O9G)C<&$H,2L@,34RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$13$T.$$Q03(W,C9#12 @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$U,R\R-38I#0ID871A." P>#-&1$4S049#,$$T.49&-# @(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-30O,C4V*0T*9&%T83@@,'@S1D1%-C$X-3(PX=0A=
M-D0U,39%(" @("\O;&]G*#$O9G)C<&$H,2L@,34U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$13@X,C4W.#@R,T0U,B @(" O+VQO9R@Q+V9R8W!A*#$K(#$U-B\R-38IX=0A=
M#0ID871A." P>#-&1$5!141$,D5!0SDY,$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-3<O,C4V*0T*9&%T83@@,'@S1D1%1#5!0S5&-#,V0D4S(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,34X+S(U-BD-"F1A=3D&$X(#!X,T9$149#.3,R-D0Q-D%"X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$U.2\R-38I#0ID871A." P>#-&1$8RX=0A=
M,SDQ03(Q-3<V,# @(" @+R]L;V<H,2]F<F-P82@Q*R Q-C O,C4V*0T*9&%TX=0A=
M83@@,'@S1D1&-$%!-T5%,#,Q.3)$(" @("\O;&]G*#$O9G)C<&$H,2L@,38QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9$1C<Q1#8R-T,S,$)"," @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$V,B\R-38I#0ID871A." P>#-&1$8Y.3%#-D-",T(S-SD@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-C,O,C4V*0T*9&%T83@@,'@S1D1&0S W041!X=0A=
M-CE!.3$P(" @("\O;&]G*#$O9G)C<&$H,2L@,38T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9$1D4W1C$X14(P,T0S12 @(" O+VQO9R@Q+V9R8W!A*#$K(#$V-2\R-38IX=0A=
M#0ID871A." P>#-&13 P-T,P-3-#-3 P,D4@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-C8O,C4V*0T*9&%T83@@,'@S1D4P,4(Y-#(Q.3A!-4$Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,38W+S(U-BD-"F1A=3D&$X(#!X,T9%,#)&-S0T,#!#-C1%X=0A=
M0B @(" O+VQO9R@Q+V9R8W!A*#$K(#$V."\R-38I#0ID871A." P>#-&13 TX=0A=
M,S8P0D4W-C S040@(" @+R]L;V<H,2]F<F-P82@Q*R Q-CDO,C4V*0T*9&%TX=0A=
M83@@,'@S1D4P-3<U.4%#-#=3D&13,T(" @("\O;&]G*#$O9G)C<&$H,2L@,3<PX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,#9"-48Q.3$Q0T8U,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$W,2\R-38I#0ID871A." P>#-&13 W.$)&,#4S,T,U-C@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q-S(O,C4V*0T*9&%T83@@,'@S1D4P.$-$.38XX=0A=
M-T4W0C!%(" @("\O;&]G*#$O9G)C<&$H,2L@,3<S+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,$$Q,# W-$-&.3 Q.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#$W-"\R-38IX=0A=
M#0ID871A." P>#-&13!"-3,T,T$R,S0T-S<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q-S4O,C4V*0T*9&%T83@@,'@S1D4P0SDW-$,X.30S,4-%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3<V+S(U-BD-"F1A=3D&$X(#!X,T9%,$1$0S(S,#5".3@XX=0A=
M-B @(" O+VQO9R@Q+V9R8W!A*#$K(#$W-R\R-38I#0ID871A." P>#-&13!%X=0A=
M0C4R-$)!1D,Y,3@@(" @+R]L;V<H,2]F<F-P82@Q*R Q-S@O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4P1D9"-30R,3-!-#<V(" @("\O;&]G*#$O9G)C<&$H,2L@,3<YX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,3$T,C4S1$$Y-T0Y1B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$X,"\R-38I#0ID871A." P>#-&13$R.$$R-$8Q1#E!1D8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.#$O,C4V*0T*9&%T83@@,'@S1D4Q,S8U,C4RX=0A=
M0D8P.#8U(" @("\O;&]G*#$O9G)C<&$H,2L@,3@R+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,31!134U.$(T03DR1" @(" O+VQO9R@Q+V9R8W!A*#$K(#$X,R\R-38IX=0A=
M#0ID871A." P>#-&13$U1C@U03$Y0S<V-4(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q.#0O,C4V*0T*9&%T83@@,'@S1D4Q-D0T1#,X0S$Q.49!(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3@U+S(U-BD-"F1A=3D&$X(#!X,T9%,3@R,#-#,C!$1#$SX=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#$X-B\R-38I#0ID871A." P>#-&13$YX=0A=
M-D,W0D,T0C%&,T(@(" @+R]L;V<H,2]F<F-P82@Q*R Q.#<O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4Q031!-S,X0C=3D!,S-#(" @("\O;&]G*#$O9G)C<&$H,2L@,3@XX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,4(Y.#%#,$,Y-C4S1" @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$X.2\R-38I#0ID871A." P>#-&13%#138Y13A"0C$P-D(@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.3 O,C4V*0T*9&%T83@@,'@S1D4Q1$,V,3E$X=0A=
M13 V.30T(" @("\O;&]G*#$O9G)C<&$H,2L@,3DQ+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,48Q-C!!,D%$,$1!-" @(" O+VQO9R@Q+V9R8W!A*#$K(#$Y,B\R-38IX=0A=
M#0ID871A." P>#-&13(P-C9$-S<T,#<S-T4@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R Q.3,O,C4V*0T*9&%T83@@,'@S1D4R,30W1$)!-#=3D!,SDT(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,3DT+S(U-BD-"F1A=3D&$X(#!X,T9%,C(Y03%"0S5%0D%#X=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#$Y-2\R-38I#0ID871A." P>#-&13(SX=0A=
M-T,Q.#0Q034P,D4@(" @+R]L;V<H,2]F<F-P82@Q*R Q.38O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4R-$-&0T4V1C@P1#E!(" @("\O;&]G*#$O9G)C<&$H,2L@,3DWX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,C5",D,U-4-$-3<V,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#$Y."\R-38I#0ID871A." P>#-&13(W,#=3D&-$0U1C=3D#-#$@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R Q.3DO,C4V*0T*9&%T83@@,'@S1D4R.#5%,#@TX=0A=
M,D-!,S@T(" @("\O;&]G*#$O9G)C<&$H,2L@,C P+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,CDT,CDT-S X0C<W,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(P,2\R-38IX=0A=
M#0ID871A." P>#-&13)!.4$R-C<P049&,$,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,#(O,C4V*0T*9&%T83@@,'@S1D4R0C=3D&0C)#.$0Q0T,Q(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C S+S(U-BD-"F1A=3D&$X(#!X,T9%,D,V-4$V,SDU1C5&X=0A=
M-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(P-"\R-38I#0ID871A." P>#-&13)$X=0A=
M0D8U-3=3D",$1&-#,@(" @+R]L;V<H,2]F<F-P82@Q*R R,#4O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4R14$V-$,S1CDW-C4U(" @("\O;&]G*#$O9G)C<&$H,2L@,C VX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,S P,3@R,S8X-$0W,R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(P-R\R-38I#0ID871A." P>#-&13,P13DW13E!.$(U0T0@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,#@O,C4V*0T*9&%T83@@,'@S1D4S,C0V,T5"X=0A=
M1$0S-$5!(" @("\O;&]G*#$O9G)C<&$H,2L@,C Y+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,S,R1C0S,31!1#<Y-B @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q,"\R-38IX=0A=
M#0ID871A." P>#-&13,T.$0Y,$4W-#8T1# @(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,3$O,C4V*0T*9&%T83@@,'@S1D4S-3<W.48X0S0S1#9%(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C$R+S(U-BD-"F1A=3D&$X(#!X,T9%,S8V,C$Y-C%!-D$YX=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q,R\R-38I#0ID871A." P>#-&13,WX=0A=
M0S(Y.48S0S,V-D$@(" @+R]L;V<H,2]F<F-P82@Q*R R,30O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4S.$%%,C$W,3DW-D4W(" @("\O;&]G*#$O9G)C<&$H,2L@,C$UX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%,SDY03$U-T$V,#-%-R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(Q-B\R-38I#0ID871A." P>#-&13-!1D-#1D4W-T(Y1#$@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,3<O,C4V*0T*9&%T83@@,'@S1D4S0D4Y1#4PX=0A=
M,S4S,T(U(" @("\O;&]G*#$O9G)C<&$H,2L@,C$X+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%,T-$-S0X,$(T03A!,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(Q.2\R-38IX=0A=
M#0ID871A." P>#-&13-%,T,T,SDQ.$8W-D,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,C O,C4V*0T*9&%T83@@,'@S1D4S1C)!0T(R-T5$-D,W(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C(Q+S(U-BD-"F1A=3D&$X(#!X,T9%-# Q.4,R,3(U0T$YX=0A=
M,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(R,B\R-38I#0ID871A." P>#-&130QX=0A=
M.#$P-C$S.#DW,C(@(" @+R]L;V<H,2]F<F-P82@Q*R R,C,O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4T,C<Q,34Q.$1&-30U(" @("\O;&]G*#$O9G)C<&$H,2L@,C(TX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-#,V,3DT13$R0C9"1B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(R-2\R-38I#0ID871A." P>#-&130T-3(X-40V.$5!-CD@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,C8O,C4V*0T*9&%T83@@,'@S1D4T-4)#0S0VX=0A=
M-$,X.3-!(" @("\O;&]G*#$O9G)C<&$H,2L@,C(W+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-#9!140R,48Q,3=3D&0R @(" O+VQO9R@Q+V9R8W!A*#$K(#(R."\R-38IX=0A=
M#0ID871A." P>#-&130W03$U,C=3D%.$$R1#,@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,CDO,C4V*0T*9&%T83@@,'@S1D4T.#DT-#5%1D9&0T-#(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C,P+S(U-BD-"F1A=3D&$X(#!X,T9%-$$P,3A"0T(V.3@SX=0A=
M-2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(S,2\R-38I#0ID871A." P>#-&131!X=0A=
M1C5!,$,Y1#8U1#<@(" @+R]L;V<H,2]F<F-P82@Q*R R,S(O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4T0D5!,D$U0D1"13@W(" @("\O;&]G*#$O9G)C<&$H,2L@,C,SX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-$-$1C(X1C$P04,T-B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(S-"\R-38I#0ID871A." P>#-&131$1#0Y0T8Y.30P-3@@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R,S4O,C4V*0T*9&%T83@@,'@S1D4T14-!.#9%X=0A=
M-C1!-C@T(" @("\O;&]G*#$O9G)C<&$H,2L@,C,V+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-3 S0S0S0T0X14(V." @(" O+VQO9R@Q+V9R8W!A*#$K(#(S-R\R-38IX=0A=
M#0ID871A." P>#-&134Q,S,U-C8V-T9#-3<@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R,S@O,C4V*0T*9&%T83@@,'@S1D4U,C)!13 W,SA!,T0X(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C,Y+S(U-BD-"F1A=3D&$X(#!X,T9%-3,R,D4R-C@V-S@UX=0A=
M-R @(" O+VQO9R@Q+V9R8W!A*#$K(#(T,"\R-38I#0ID871A." P>#-&134TX=0A=
M,4(U0T(Y-SDX,#D@(" @+R]L;V<H,2]F<F-P82@Q*R R-#$O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4U-3$T-$9$0D-"1#8R(" @("\O;&]G*#$O9G)C<&$H,2L@,C0RX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-38P1$)#-#4Q-3-#-R @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(T,R\R-38I#0ID871A." P>#-&134W,#=3D!,C9"0CA#-C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R-#0O,C4V*0T*9&%T83@@,'@S1D4U.#=3D&-C!%X=0A=
M1#5".3 P(" @("\O;&]G*#$O9G)C<&$H,2L@,C0U+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-3DW03<Y-S=3D#.$8S,2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(T-B\R-38IX=0A=
M#0ID871A." P>#-&135!-S8P1#8S-$)".$(@(" @+R]L;V<H,2]F<F-P82@QX=0A=
M*R R-#<O,C4V*0T*9&%T83@@,'@S1D4U0C<R,40R.35&,3!&(" @("\O;&]GX=0A=
M*#$O9G)C<&$H,2L@,C0X+S(U-BD-"F1A=3D&$X(#!X,T9%-4,V14$Y-#0S,45&X=0A=
M.2 @(" O+VQO9R@Q+V9R8W!A*#$K(#(T.2\R-38I#0ID871A." P>#-&135$X=0A=
M-D)",C)%03@V1C8@(" @+R]L;V<H,2]F<F-P82@Q*R R-3 O,C4V*0T*9&%TX=0A=
M83@@,'@S1D4U138Y,S@V-#5$,SDP(" @("\O;&]G*#$O9G)C<&$H,2L@,C4QX=0A=
M+S(U-BD-"F1A=3D&$X(#!X,T9%-48V-S-#-C%!,D5$,B @(" O+VQO9R@Q+V9RX=0A=
M8W!A*#$K(#(U,B\R-38I#0ID871A." P>#-&138P-C5"14$S.#4Y,C8@(" @X=0A=
M+R]L;V<H,2]F<F-P82@Q*R R-3,O,C4V*0T*9&%T83@@,'@S1D4V,38T0D9!X=0A=
M-T-#,#9"(" @("\O;&]G*#$O9G)C<&$H,2L@,C4T+S(U-BD-"F1A=3D&$X(#!XX=0A=
M,T9%-C(V-#-&14-&.3<T,R @(" O+VQO9R@Q+V9R8W!A*#$K(#(U-2\R-38IX=0A=
M#0H-"BYG;&]B86P@;&]G9@T*+F=3DL;V)A;"!L;V<Q,&8-"@T*+G1E>'0-"BYPX=0A=
M<F]C("!L;V<Q,&8-"BYA;&EG;B S,@T*;&]G,3!F.@T*#0I[(" @(" N;69IX=0A=
M#0H@(" @(&%L;&]C(" @(" @<C,R(" @(" @(" @(" ](&%R+G!F<RPQ+#$QX=0A=
M+#0L, T*(" @("!F<F-P82YS,2 @;&]G7T(L<#$U(" @(" @/2 @("!F,2QFX=0A=
M. T*(" @("!A9&1L(" @(" @3$]'7T%$7T-/149&(" @/2 @("! ;'1O9F8HX=0A=
M;&]G7V-O969F7W1A8FQE*2QG< T*?0T*>R @(" @+FUF:0T*(" @("!M;W8@X=0A=
M(" @(" @3$]'7VUA<VL@(" @(" @(" @(" ](" @(#!X,49&1D8-"B @(" @X=0A=
M9FYO<FTN<S$@(&QO9U]X7VYO<FT@(" @(" @(" @/2 @("!F. T*(" @("!AX=0A=
M9&1L(" @(" @3$]'7T%$7T-/3E-404Y44R @(" ](" @($!L=3D&]F9BAL;V=3D?X=0A=
M8V]N<W1A;G1S7W1A8FQE*2QG<#L[#0I]#0H-"GL@(" @("YM9FD-"B @(" @X=0A=
M;6]V(" @(" @(" @(" @3$]'7T9&1C<@(#T@(" @,'A&1D8W#0H@(" @(&9CX=0A=
M;&%S<RYM+G5N8R @(' X+' P(" @(" ](" @(&8X+#!X-PDO+R! >F5R;PT*X=0A=
M(" @("!S:'(@(" @(" @(" @("!,3T=3D?8FEA<R @/2 @("!,3T=3D?;6%S:RPQX=0A=
M#0I]#0I[(" @(" N;69I#0H@(" @(&YO<"YM(" @(" @(" @(" @(" @(" YX=0A=
M.3D-"B @(" @9FUS+G,Q(" @(&QO9U]S(" @(" @(" @(#T@(" @9C$L9C@LX=0A=
M9C$-"B @(" @8VUP+F5Q(" @(' V+' W(" @(" @(" @(#T@(" @<C L<C @X=0A=
M.SL@#0I]#0H-"GL@(" @("YM9FD-"B @(" @;&0X(" @(" @($Q/1U]!1%]#X=0A=
M3T5&1B @(#T@(" @6TQ/1U]!1%]#3T5&1ET-"B @(" @;F]P+F8@(" @(" @X=0A=
M(" @(" @(" @(" @(" @.3DY#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @X=0A=
M(" @(" @(#DY.0T*?0T*>R @(" @+FUF8@T*(" @("!L9#@@(" @(" @3$]'X=0A=
M7T%$7T-/3E-404Y44R @(" ](" @(%M,3T=3D?041?0T].4U1!3E1370T*(" @X=0A=
M("!N;W N9B @(" @(" @(" @(" @(" @(" @(" @(" @(#DY.0T*(" @("!BX=0A=
M<BYS<'1K(" @3$]'1E],3T<Q,$9?0T]-34].#0I]#0H-"@T*+F5N9' @;&]GX=0A=
M,3!F#0H-"@T*+G1E>'0-"BYP<F]C("!L;V=3DF#0HN86QI9VX@,S(-"FQO9V8ZX=0A=
M#0H-"@T*>R @(" @+FUF:2 -"B @(" @86QL;V,@(" @("!R,S(@(" @(" @X=0A=
M(" @(#T@87(N<&9S+#$L,3$L-"PP#0H@(" @(&9R8W!A+G,Q("!L;V=3D?0BQPX=0A=
M,34@(" @(" ](" @(&8Q+&8X#0H@(" @(&%D9&P@(" @("!,3T=3D?041?0T]%X=0A=
M1D8@(" ](" @($!L=3D&]F9BAL;V=3D?8V]E9F9?=3D&%B;&4I+&=3DP#0I]( T*>R =
@X=0A=
M(" @+FUF:2 -"B @(" @;6]V(" @(" @($Q/1U]M87-K(" @(" @(" @(" @X=0A=
M/2 @(" P>#%&1D9&#0H@(" @(&9N;W)M+G,Q("!L;V=3D?>%]N;W)M(" @(" @X=0A=
M(" @(#T@(" @9C@-"B @(" @861D;" @(" @($Q/1U]!1%]#3TY35$%.5%,@X=0A=
M(" @/2 @("! ;'1O9F8H;&]G7V-O;G-T86YT<U]T86)L92DL9W [.PT*?0T*X=0A=
M#0H@#0I[(" @(" N;69I( T*(" @("!M;W8@(" @(" @(" @("!,3T=3D?1D9&X=0A=
M-R @/2 @(" P>$9&1C<-"B @(" @9F-L87-S+FTN=3D6YC(" @<#@L<# @(" @X=0A=
M(#T@(" @9C@L,'@W"2\O($!Z97)O#0H@(" @('-H<B @(" @(" @(" @($Q/X=0A=
M1U]B:6%S(" ](" @($Q/1U]M87-K+#$-"GT@#0I[(" @(" N;69I( T*(" @X=0A=
M("!N;W N;2 @(" @(" @(" @(" @(" @.3DY#0H@(" @(&9M<RYS,2 @("!LX=0A=
M;V=3D?<R @(" @(" @(" ](" @(&8Q+&8X+&8Q#0H@(" @(&-M<"YE<2 @("!PX=0A=
M-RQP-B @(" @(" @(" ](" @('(P+'(P(#L[( T*?0T*#0H@#0H-"GL@(" @X=0A=
M("YM9FD@#0H@(" @(&QD." @(" @("!,3T=3D?041?0T]%1D8@(" ](" @(%M,X=0A=
M3T=3D?041?0T]%1D9=3D#0H@(" @(&YO<"YF(" @(" @(" @(" @(" @(" @(" @X=0A=
M(#DY.0T*(" @("!N;W N:2 @(" @(" @(" @(" @(" @(" @(" Y.3D-"GT@X=0A=
M#0I[(" @(" N;69I( T*(" @("!L9#@@(" @(" @3$]'7T%$7T-/3E-404Y4X=0A=
M4R @(" ](" @(%M,3T=3D?041?0T].4U1!3E1370T*(" @("!N;W N9B @(" @X=0A=
M(" @(" @(" @(" @(" @(" @(" @(#DY.0T*(" @("!N;W N:2 @(" @(" @X=0A=
M(" @(" @(" @(" @(" @(" @(#DY.3L[#0I]#0H-"B -"DQ/1T9?3$]',3!&X=0A=
M7T-/34U/3CH-"@T*>R @(" @+FUF:2 -"B @(" @;&1F<&0@(" @(&QO9U]CX=0A=
M;V5F9E]P,RQL;V=3D?8V]E9F9?<#(@(" @(#T@(" @6TQ/1U]!1%]#3T5&1ETLX=0A=
M,38-"B @(" @9FUS+G,Q(" @(&QO9U]R(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(#T@(" @9C@L;&]G7T(L9C$-"B @(" @;F]P+FD@(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" @(" @(" @(" @(" @.3DY#0I]( T*>R @(" @+FUF8B -X=0A=
M"B @(" @;&1F<&0@(" @(&QO9U]C;V5F9E]P,2QL;V=3D?8V]N<W1?;&]G,B @X=0A=
M(#T@(" @6TQ/1U]!1%]#3TY35$%.5%-=3D+#$V#0H@(" @(&YO<"YF(" @(" @X=0A=
M(" @(" @(" @(" @(" @(" @(" @(" @(" @(" @(#DY.0T**' X*2!B<BYCX=0A=
M;VYD+G-P;G0@("!,3T=3D?3D%.7TE.1E].14=3D?6D523R @(" @(" [.PT*?0T*X=0A=
M#0H@#0I[(" @(" N;69I( T*(" @("!L9&9P9" @(" @;&]G7W1H<F5S:&AOX=0A=
M;&0L(&QO9U]I;G9?;&XQ," ](" @(%M,3T=3D?041?0T].4U1!3E1372PQ-@T*X=0A=
M(" @("!F;6$N<S$@(" @;&]G7W-S<2 @(" @(" @/2 @("!L;V=3D?<RQL;V=3D?X=0A=
M<RQF, T*(" @("!N;W N:2 @(" @(" @(" @(" @(" @(" @(" Y.3D[.PT*X=0A=
M?2 -"B -"GL@(" @("YM9FD@#0H@(" @(&=3DE=3D&8N97AP("!,3T=3D?>%]S97APX=0A=
M(" @(" ](" @(&QO9U]X7VYO<FT-"B @(" @9FUE<F=3DE+G,@(&QO9U]A8G-?X=0A=
M<R @(" @(#T@(" @9C$L;&]G7W,-"B @(" @;F]P+FD@(" @(" @(" @(" @X=0A=
M(" @(" @(" @.3DY.SL-"GT@#0H@#0I[(" @(" N;69I( T*(" @("!G971FX=0A=
M+G-I9R @3$]'7WA?:6YD(#T@(" @;&]G7WA?;F]R;0T*(" @("!N;W N9B @X=0A=
M(" @(" @(" @(" @(" @.3DY#0H@(" @(&YO<"YI(" @(" @(" @(" @(" @X=0A=
M(" Y.3D[.PT*?2 -"B -"GL@(" @("YM9FD@#0H@(" @(&%N9" @(" @("!,X=0A=
M3T=3D?>%]N(" @/2 @("!,3T=3D?>%]S97AP+$Q/1U]M87-K#0H@(" @(&9M82YSX=0A=
M,2 @("!L;V=3D?<G-Q(" @/2 @("!L;V=3D?<BQL;V=3D?<BQF, T*(" @("!C;7 NX=0A=
M9V4@(" @<#$P+' P(" @(#T@(" @3$]'7WA?<V5X<"Q,3T=3D?;6%S:SL[#0I]X=0A=
M( T*( T*>R @(" @+FUF:2 -"B @(" @<W5B(" @(" @($Q/1U]X7VX@(" ]X=0A=
M(" @($Q/1U]X7VXL3$]'7V)I87,-"B @(" @;F]P+F8@(" @(" @(" @(" @X=0A=
M(" @(#DY.0T*(" @("!S:&P@(" @(" @3$]'7WA?:6YD(#T@(" @3$]'7WA?X=0A=
M:6YD+#$[.PT*?2 -"B -"GL@(" @("YM9FD@#0H@(" @('-E=3D&8N<VEG("!LX=0A=
M;V=3D?;B @(" @/2 @("!,3T=3D?>%]N#0H@(" @(&YO<"YF(" @(" @(" @(" @X=0A=
M(" @(" Y.3D-"B @(" @<VAR+G4@(" @($Q/1U]X7VEN9" ](" @($Q/1U]XX=0A=
M7VEN9"PU-CL[#0I]( T*( T*>R @(" @+FUF:2 -"B @(" @;F]P+FT@(" @X=0A=
M(" @(" @(" @(" @(#DY.0T*(" @("!N;W N9B @(" @(" @(" @(" @(" @X=0A=
M.3DY#0H@(" @('-H;" @(" @("!,3T=3D?>%]I;F0@/2 @("!,3T=3D?>%]I;F0LX=0A=
M,SL[#0I]( T*( T*>R @(" @+FUF:2 -"B @(" @;F]P+FT@(" @(" @(" @X=0A=
M(" @(" @(" @(" @.3DY#0H@(" @(&9M82YS,2 @("!L;V=3D?<&]L>5]Q,2 @X=0A=
M(" ](" @(&QO9U]S+&QO9U]C;V5F9E]P,RQL;V=3D?8V]E9F9?<#(-"B @(" @X=0A=
M;F]P+FD@(" @(" @(" @(" @(" @(" @(" @.3DY#0I]( T*>R @(" @+FUFX=0A=
M:2 -"B @(" @;F]P+FT@(" @(" @(" @(" @(" @(" @(" @.3DY#0H@(" @X=0A=
M(&9M82YS,2 @("!L;V=3D?<&]L>5]P,2 @(" ](" @(&QO9U]R+&QO9U]C;V5FX=0A=
M9E]P,RQL;V=3D?8V]E9F9?<#(-"B @(" @;F]P+FD@(" @(" @(" @(" @(" @X=0A=
M(" @(" @.3DY.SL-"GT-"@T*( T*>R @(" @+FUF8B -"B @(" @(" @("!AX=0A=
M9&0@(" @(" @(" @("!,3T=3D?041?0T].4U1!3E13(" @(" @(" @/2 @("!,X=0A=
M3T=3D?041?0T].4U1!3E13+$Q/1U]X7VEN9 T*(" @(" @(" @(&9C;7 N;'0NX=0A=
M<S$@(" @(' Q,2QP,3(@(" @(" @(" @(" @(" @(" ](" @(&QO9U]A8G-?X=0A=
M<RQL;V=3D?=3D&AR97-H:&]L9 T**' Q,"D@(" @(&)R+F-O;F0N<W!N=3D" @($Q/X=0A=
M1U].04Y?24Y&7TY%1U]:15)/(" @(" @(#L[#0I]( T*( T*>R @(" @+FUFX=0A=
M:2 -"B @(" @;&1F9" @(" @(&QO9U]4(" @(" ](" @(%M,3T=3D?041?0T].X=0A=
M4U1!3E1370T*(" @("!N;W N9B @(" @(" @(" @(" @(" @.3DY#0H@(" @X=0A=
M(&YO<"YI(" @(" @(" @(" @(" @(" Y.3D[.PT*?2 -"B -"GL@(" @("YMX=0A=
M9FD@#0H@(" @(&YO<"YM(" @(" @(" @(" @(" @(" @(" @(#DY.0T*(" @X=0A=
M("!F;6$N<S$@(" @;&]G7W!O;'E?<3(@(" @/2 @("!L;V=3D?<RQL;V=3D?<&]LX=0A=
M>5]Q,2QL;V=3D?8V]E9F9?<#$-"B @(" @;F]P+FD@(" @(" @(" @(" @(" @X=0A=
M(" @(" @.3DY#0I]( T*>R @(" @+FUF:2 -"B @(" @;F]P+FT@(" @(" @X=0A=
M(" @(" @(" @(" @(" @.3DY#0H@(" @(&9M82YS,2 @("!L;V=3D?<&]L>5]PX=0A=
M,B @(" ](" @(&QO9U]R+&QO9U]P;VQY7W Q+&QO9U]C;V5F9E]P,0T*(" @X=0A=
M("!N;W N:2 @(" @(" @(" @(" @(" @(" @(" Y.3D[.PT*?0T*#0H@#0I[X=0A=
M(" @(" N;69I( T*(" @("!N;W N;2 @(" @(" @(" @(" @(" @.3DY#0H@X=0A=
M(" @(&9C=3DG0N>&8@("!L;V=3D?;B @(" @/2 @("!L;V=3D?;@T*(" @("!N;W NX=0A=
M:2 @(" @(" @(" @(" @(" @.3DY.SL-"GT@#0H@#0I[(" @(" N;69I( T*X=0A=
M(" @(" @(" @(&YO<"YM(" @(" @(" @(" @.3DY#0HH<#$Q*2 @(" @9FUAX=0A=
M+G,@(" @(&8X(" @/2 @("!L;V=3D?<W-Q+&QO9U]P;VQY7W$R+&QO9U]S#0H@X=0A=
M(" @(" @(" @;F]P+FD@(" @(" @(" @(" Y.3D-"GT@#0I[(" @(" N;69IX=0A=
M( T*(" @("!N;W N;2 @(" @(" @(" @(" @(" @(" @(" Y.3D-"B @(" @X=0A=
M9FUA+G,Q(" @(&QO9U]P;VQY7W S(" @(#T@(" @;&]G7W)S<2QL;V=3D?<&]LX=0A=
M>5]P,BQL;V=3D?<@T*(" @("!N;W N:2 @(" @(" @(" @(" @(" @(" @(" YX=0A=
M.3D[.PT*?0T*#0I[(" @(" N;69I( T*(" @(" @;F]P+FT@.3DY#0HH<#$QX=0A=
M*2!F;6$N<S$@(" @(" @;&]G,3!?9C@@/2!L;V=3D?<W-Q+&QO9U]P;VQY7W$RX=0A=
M+&QO9U]S#0H@(" @("!N;W N:2 Y.3D-"GT-"CL[#0H-"@T*#0H@#0I[(" @X=0A=
M(" N;69I( T*(" @("!N;W N;2 @(" @(" @(" @(" @(" @.3DY#0H@(" @X=0A=
M(&9M82YS,2 @("!L;V=3D?5" @(" @/2 @("!L;V=3D?;BQL;V=3D?8V]N<W1?;&]GX=0A=
M,BQL;V=3D?5 T*(" @("!N;W N:2 @(" @(" @(" @(" @(" @.3DY.SL-"GT@X=0A=
M#0H@#0I[(" @(" N;69B( T*(" @(" @(" @(&YO<"YM(" @(" @(" @(" @X=0A=
M.3DY#0HH<#$R*2 @(" @9FUA+G,@(" @(&8X(" @/2 @("!L;V=3D?5"QF,2QLX=0A=
M;V=3D?<&]L>5]P,PT*(" @(" @(" @(&YO<"YB(#DY.0T*?2 -"@T*#0I[(" @X=0A=
M(" N;69B( T*(" @(" @(" @(&YO<"YM(#DY.0T**' Q,BD@(" @(&9M82YSX=0A=
M,2 @("!L;V<Q,%]F." @(#T@(" @;&]G7U0L9C$L;&]G7W!O;'E?<#,-"B @X=0A=
M(" @(" @("!N;W N8B Y.3D-"GT-"CL[#0H-"GL@(" @("YM9F(@#0H@(" @X=0A=
M(" @(" @;F]P+FT@.3DY#0HH<#8I(" @(" @9FUA+G,@(" @(&8X(" @/2 @X=0A=
M("!L;V=3D?:6YV7VQN,3 L(&QO9S$P7V8X+"!F, T*(" @(" @(" @(&)R+G)EX=0A=
M=3D"YS<'1K(" @(&(P(" @#0I]#0H[.PT*#0H-"B -"DQ/1U].04Y?24Y&7TY%X=0A=
M1U]:15)/.@T*#0HO+R @($QO9UMI;F9=3D(" @(" @/2!I;F8-"@T*+R\@("!,X=0A=
M;V=3D;,%T@(" @(" @(#T@+6EN9FEN:71Y+" @(" @("!C86QL(&5R<F]R('-UX=0A=
M<'!O<G0L('1A9R T#0HO+R @($QO9ULM,%T@(" @(" @/2 M:6YF:6YI=3D'DLX=0A=
M(" @(" @(&-A;&P@97)R;W(@<W5P<&]R=3D"P@=3D&%G(#0-"@T*+R\@("!,;V=3D;X=0A=
M+6YO;GIE<F]=3D(#T@<6YA;B!I;F1E9FEN:71E+"!C86QL(&5R<F]R('-U<'!OX=0A=
M<G0L('1A9R U#0HO+R @($QO9ULM:6YF72 @(" @/2!Q;F%N(&EN9&5F:6YIX=0A=
M=3D&4L(&-A;&P@97)R;W(@<W5P<&]R=3D"P@=3D&%G(#4-"@T*+R\@("!,;V=3D;,%T@X=0A=
M(" @(" @(#T@+6EN9FEN:71Y+" @(" @("!C86QL(&5R<F]R('-U<'!O<G0LX=0A=
M('1A9R Q, T*+R\@("!,;V=3D;+3!=3D(" @(" @(#T@+6EN9FEN:71Y+" @(" @X=0A=
M("!C86QL(&5R<F]R('-U<'!O<G0L('1A9R Q, T*#0HO+R @($QO9ULM;F]NX=0A=
M>F5R;UT@/2!Q;F%N(&EN9&5F:6YI=3D&4L(&-A;&P@97)R;W(@<W5P<&]R=3D"P@X=0A=
M=3D&%G(#$Q#0HO+R @($QO9ULM:6YF72 @(" @/2!Q;F%N(&EN9&5F:6YI=3D&4LX=0A=
M(&-A;&P@97)R;W(@<W5P<&]R=3D"P@=3D&%G(#$Q#0H-"B\O(" @3&]G6TYA;ET@X=0A=
M(" @(" ]('%U:71E($YA3@T*#0HO+R\O+R\O+R\O+R\O+R\O+R\O+R\O+PT*X=0A=
M+R\@:68@>"!I<R!.86XL(&QE879E(&EM;65D:6%T96QY#0H@(" @("!F8VQAX=0A=
M<W,N;2YU;F,@(" @(' X+' P(" @(" @(" @(#T@9C@L,'AC,PDO+R! <VYAX=0A=
M;B!\($!Q;F%N#0H[.PT**' X*2 @9FYO<FT@(" @(" @(" @("!F." @(" @X=0A=
M(" @(" @(" ](&8X#0H[.PT**' X*2 @8G(N<F5T+G-P;G0@(" @("!B, T*X=0A=
M#0H-"B\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O#0HO+R!I9B!X(&ES("MI;F9IX=0A=
M;FET>2P@;&5A=3DF4@:6UM961I871E;'D-"B @(" @(&9C;&%S<RYM+G5N8R @X=0A=
M(" @<#@L<# @(" @(" @(" @/2!F."PP>#(Q"2\O($!I;F8@?"! <&]S#0H[X=0A=
M.PT**' X*2 @9G)C<&$N<S$@(" @(" @("!F."QP,34@(" @(" @(" ](&8QX=0A=
M+&8P#0H[.PT**' X*2 @8G(N<F5T+G-P;G0@(" @("!B, T*#0H-"B\O(&5LX=0A=
M<V4@:68@>"!I<R!Z97)O+"!S970@=3D&%G('1O(#0@*&QO9V8I(&]R(#$P("ALX=0A=
M;V<Q,&8I(&%N9"!C86QL(&5R<F]R('-U<'!O<G0-"B\O($QO9ULK+3!=3D(#T@X=0A=
M+6EN9FEN:71Y+"!W:71H(&1B>B!S970N(%)A;F=3DE(&5R<F]R#0H-"B @(" @X=0A=
M(&9C;&%S<RYM+G5N8R @(" @<#@L<#D@(" @(" @(" @/2!F."PP>#<)+R\@X=0A=
M0'IE<F\-"CL[#0HH<#@I("!F<F-P82 @(" @(" @(" @(&8X+' Q-2 @(" @X=0A=
M(" @(#T@9C$L9C -"CL[#0H-"BYP<F5D+G)E;" B;75T97@B+' W+' V#0HHX=0A=
M<#@I("!F;65R9V4N;G,@(" @(" @(&8X(" @(" @(" @(" @(#T@9C@L9C@-X=0A=
M"BAP-RD@(&UO=3DB @(" @(" @(" @(" @3$]'7W1A9R @(" @(" @/2 T#0HHX=0A=
M<#8I("!M;W8@(" @(" @(" @(" @($Q/1U]T86<@(" @(" @(#T@,3 -"@T*X=0A=
M*' X*2 @8G(N8V]N9"YS<&YT(" @("!?7VQI8FU?97)R;W)?<F5G:6]N#0H-X=0A=
M"B\O(&5L<V4@:68@>"!I<R M;F]N+7IE<F\L('-E=3D"!T86<@=3D&\@-2!A;F0@X=0A=
M8V%L;"!E<G)O<B!S=3D7!P;W)T#0HO+R!,;V=3D;+6YO<FTL("UU;F]R;2P@+6ENX=0A=
M9ET@/2!Q;F%N(&EN9&5F:6YI=3D&4L(&EN=3DF%L:60@<V5T+"!D;VUA:6X@97)RX=0A=
M;W(-"@T**' Y*2 @9F-L87-S+FTN=3D6YC(" @("!P,3 L(' P(" @(" @(" @X=0A=
M/2!F."PP>#-A"2\O($!I;F8@?"! ;F]R;2!\($!U;F]R;2!\($!N96<-"CL[X=0A=
M#0HH<#$P*2 @9G)C<&$N<S @(" @(" @(&8X+' Q-2 @(" @(" @(#T@9C LX=0A=
M9C -"BAP-RD@(&UO=3DB @(" @(" @(" @(" @3$]'7W1A9R @(" @(" @/2 UX=0A=
M#0HH<#8I("!M;W8@(" @(" @(" @(" @($Q/1U]T86<@(" @(" @(#T@,3$-X=0A=
M"@T*(" @(" @8G(N8V]N9"YS<&YT(" @("!?7VQI8FU?97)R;W)?<F5G:6]NX=0A=
M#0H-"BYE;F1P(&QO9V8-"@T*#0H-"@T*+R\O+R\O+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\OX=0A=
M+PT*+R\@17)R;W(@:&%N9&QI;F<@<F5G:6]N#0HO+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\O+R\OX=0A=
M+R\O+R\O#0H-"@T*#0HO+R!3=3D&%C:R!O<&5R871I;VYS('=3DH96X@8V%L;&ENX=0A=
M9R!E<G)O<B!S=3D7!P;W)T+@T*+R\@(" @(" @*#$I(" @(" @(" @(" @(" @X=0A=
M(" @("@R*0T*+R\@("!S<" @("T^("L@(" @(" @(" @(" @(" @('!S<" MX=0A=
M/B K#0HO+R @(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @('P-X=0A=
M"B\O(" @(" @(" @("!\(" @(" @(" @(" @(" @(" @(" @(" @?" \+2!'X=0A=
M4E]9#0HO+R @(" @(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @('P-X=0A=
M"B\O(" @(" @(" @("!\(#PM1U)?62 @(" @(" @(" @("!9,BT^? T*+R\@X=0A=
M(" @(" @(" @('P@(" @(" @(" @(" @(" @(" @(" @("!\#0HO+R @(" @X=0A=
M(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @('P@/"T@1U)?6 T*+R\@X=0A=
M(" @(" @(" @('P@(" @(" @(" @(" @(" @(" @(" @("!\#0HO+R @<W MX=0A=
M-C0@+3X@*R @(" @(" @(" @(" @(" @<W @+3X@("L-"B\O(" @('-A=3DF4@X=0A=
M87(N<&9S(" @(" @(" @(" @(" @("!S879E(&(P#0HO+R @("!S879E(&=3DPX=0A=
M#0H-"@T*#0HO+R @(" @("@S*2 H8V%L;"D@(" @(" @(" @(" @("@T*0T*X=0A=
M+R\@("!P<W @+3X@*R @(" @(" @(" @(" @(" @("!S<" M/B K#0HO+R @X=0A=
M(" @(" @("!\(" @(" @(" @(" @(" @(" @(" @(" @('P-"B\O(" @("!2X=0A=
M,R M/GP@/"T@1U)?4D5354Q4(" @(" @(" @(" @?" M/B!F. T*+R\@(" @X=0A=
M(" @(" @?" @(" @(" @(" @(" @(" @(" @(" @("!\#0HO+R @(" @63(@X=0A=
M+3Y\(#PM($=3D27UD@(" @(" @(" @(" @(" @('P-"B\O(" @(" @(" @('P@X=0A=
M(" @(" @(" @(" @(" @(" @(" @(" @? T*+R\@(" @(%@Q("T^?" @(" @X=0A=
M(" @(" @(" @(" @(" @(" @("!\#0HO+R @(" @(" @("!\(" @(" @(" @X=0A=
M(" @(" @(" @(" @(" @('P-"B\O(" @<W @+3X@("L@(" @(" @(" @(" @X=0A=
M(" @(" @(" @(" @*PT*+R\@(" @(" @(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @("!R97-T;W)E(&=3DP#0HO+R @(" @(" @(" @(" @(" @(" @(" @(" @X=0A=
M(" @(" @(')E<W1O<F4@87(N<&9S#0H-"BYP<F]C(%]?;&EB;5]E<G)O<E]RX=0A=
M96=3DI;VX-"E]?;&EB;5]E<G)O<E]R96=3DI;VXZ#0HN<')O;&]G=3D64-"@T*+R\@X=0A=
M*#$I#0I[("YM9FD-"B @(" @(" @861D(" @1U)?4&%R86UE=3D&5R7UD]+3,RX=0A=
M+'-P(" @(" @(" @(" @("\O(%!A<F%M971E<B R('9A;'5E#0H@(" @(" @X=0A=
M(&YO<"YF(# -"BYS879E(" @87(N<&9S+$=3D27U-!5D5?4$93#0H@(" @(" @X=0A=
M(&UO=3DB @1U)?4T%615]01E,]87(N<&9S(" @(" @(" @(" @(" @(" O+R!3X=0A=
M879E(&%R+G!F<PT*?0T*>R N;69I#0HN9F9R86UE(#8T#0H@(" @(" @(&%DX=0A=
M9"!S<#TM-C0L<W @(" @(" @(" @(" @(" @(" @(" @(" @(" O+R!#<F5AX=0A=
M=3D&4@;F5W('-T86-K#0H@(" @(" @(&YO<"YF(# -"B @(" @(" @;6]V($=3D2X=0A=
M7U-!5D5?1U ]9W @(" @(" @(" @(" @(" @(" @(" @("\O(%-A=3DF4@9W -X=0A=
M"GT[.PT*#0H-"B\O("@R*0T*>R N;6UI#0H@(" @(" @('-T9G,@6T=3D27U!AX=0A=
M<F%M971E<E]972 ](&8Q+#$V(" @(" @(" @("\O(%-43U)%(%!A<F%M971EX=0A=
M<B R(&]N('-T86-K#0H@(" @(" @(&%D9"!'4E]087)A;65T97)?6" ](#$VX=0A=
M+'-P(" @(" @(" @(" @("\O(%!A<F%M971E<B Q(&%D9')E<W,-"BYS879EX=0A=
M(" @8C L($=3D27U-!5D5?0C -"B @(" @(" @;6]V($=3D27U-!5D5?0C ]8C @X=0A=
M(" @(" @(" @(" @(" @(" @(" @+R\@4V%V92!B, T*?3L[#0H-"BYB;V1YX=0A=
M#0HO+R H,RD-"GL@+FUI8@T*(" @(" @("!S=3D&9S(%M'4E]087)A;65T97)?X=0A=
M6%T@/2!L;V=3D?>%]N;W)M(" @(" @(" @(" O+R!35$]212!087)A;65T97(@X=0A=
M,2!O;B!S=3D&%C:PT*(" @(" @("!A9&0@("!'4E]087)A;65T97)?4D5354Q4X=0A=
M(#T@,"Q'4E]087)A;65T97)?62 @+R\@4&%R86UE=3D&5R(#,@861D<F5S<PT*X=0A=
M(" @(" @("!N;W N8B P#0I]#0I[("YM:6(-"B @(" @(" @<W1F<R!;1U)?X=0A=
M4&%R86UE=3D&5R7UE=3D(#T@9C@@(" @(" @(" @(" @(" @(" @("\O(%-43U)%X=0A=
M(%!A<F%M971E<B S(&]N('-T86-K#0H@(" @(" @(&%D9" @($=3D27U!A<F%MX=0A=
M971E<E]9(#T@+3$V+$=3D27U!A<F%M971E<E]9#0H@(" @(" @(&)R+F-A;&PNX=0A=
M<W!T:R!B,#U?7VQI8FU?97)R;W)?<W5P<&]R=3D" @(" @(" @("\O($-A;&P@X=0A=
M97)R;W(@:&%N9&QI;F<@9G5N8W1I;VX-"GT[.PT*#0H-"GL@+FUM:0T*(" @X=0A=
M(" @("!L9&9S("!F." ](%M'4E]087)A;65T97)?4D5354Q472 @(" @(" OX=0A=
M+R!'970@<F5T=3D7)N(')E<W5L=3D"!O9F8@<W1A8VL-"BYR97-T;W)E#0H@(" @X=0A=
M(" @(&%D9" @('-P(#T@-C0L<W @(" @(" @(" @(" @(" @(" @(" @("\OX=0A=
M(%)E<W1O<F4@<W1A8VL@<&]I;G1E<@T*(" @(" @("!M;W8@("!B," ]($=3D2X=0A=
M7U-!5D5?0C @(" @(" @(" @(" @(" @(" O+R!297-T;W)E(')E=3D'5R;B!AX=0A=
M9&1R97-S#0I].SL-"@T*>R N;6EB#0H@(" @(" @(&UO=3DB @(&=3DP(#T@1U)?X=0A=
M4T%615]'4" @(" @(" @(" @(" @(" @("\O(%)E<W1O<F4@9W -"B @(" @X=0A=
M(" @;6]V(" @87(N<&9S(#T@1U)?4T%615]01E,@(" @(" @(" @(" @+R\@X=0A=
M4F5S=3D&]R92!A<BYP9G,-"B @(" @(" @8G(N<F5T+G-P=3D&L@(" @(&(P(" @X=0A=
M(" @(" @(" @(" @(" @(" @+R\@4F5T=3D7)N#0I].SL-"@T*+F5N9' @7U]LX=0A=
M:6)M7V5R<F]R7W)E9VEO;@T*#0H-"BYT>7!E(" @7U]L:6)M7V5R<F]R7W-UX=0A=
M<'!O<G0L0&9U;F-T:6]N#0HN9VQO8F%L(%]?;&EB;5]E<G)O<E]S=3D7!P;W)TX=0A=
"#0IO                                                        X=0A=
                                                             X=0A=
end=0A=
@eof=0A=
=0A=
chmod 600 logf_ok.s=0A=
=0A=
echo x - makefile=0A=
sed 's/^@//' >makefile <<'@EOF'=0A=
@.SUFFIXES: .o .s .c=0A=
=0A=
#####################=0A=
###### TARGETS ######=0A=
#####################=0A=
=0A=
all: bad_one ok_one=0A=
=0A=
#####################=0A=
=0A=
DFLAGS  =3D -DSIZE_INT_32=0A=
EDFLAGS =3D -fno-default-inline -DLITTLE_ENDIAN -DQUAD -DWIN32 =
-DSIZE_INT_32 -D_STDC_=0A=
=0A=
bad_one: logf_bad.o =0A=
	gcc $(EDFLAGS) -o ./bad_one ./test.c ./logf_bad.o =0A=
=0A=
ok_one: logf_ok.o =0A=
	gcc $(EDFLAGS) -o ./ok_one ./test.c ./logf_ok.o=0A=
=0A=
logf_bad.o: logf_bad.s=0A=
	as -o ./logf_bad.o ./logf_bad.s=0A=
=0A=
logf_ok.o: logf_ok.s=0A=
	as -o ./logf_ok.o ./logf_ok.s=0A=
clean:=0A=
	rm -f ./*.o ./bad_one ./ok_one=0A=
@EOF=0A=
=0A=
chmod 644 makefile=0A=
=0A=
rm -f /tmp/unpack$$=0A=
exit 0=0A=

------_=_NextPart_000_01C0016F.FF2ADA50--


