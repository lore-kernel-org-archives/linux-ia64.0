From: Martin Pool <mbp@samba.org>
Date: Mon, 28 Apr 2003 06:29:49 +0000
Subject: [Linux-ia64] building an ia64 cross toolchain on debian?
Message-Id: <marc-linux-ia64-105590723705612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Apologies if this isn't the appropriate list.)

I'm trying to build an i386->ia64 cross compiler on Debian sid as
described here:

  http://www.gelato.unsw.edu.au/IA64wiki/CrossCompilation

and in the toolchain-source manual.

There are errors about dh_split being missing, but they don't seem to
interrupt the build process.

toolchain-source shows these messages at startup:

$ tpkg-make ia64-unknown-linux
Target                    : ia64-unknown-linux
Maintainer                : Martin Pool
Email-Address             : mbp@samba.org
Toolchain                 : 3.2-7
  binutils                : 2.13.90.0.18
  gcc                     : 3.2.3.cvs20030221
  gdb                     : 5.3

The build gets a fair way through but fails when trying to build ld:

flex   ../../src/ld/ldlex.l && mv lex.yy.c ldlex.c
gcc -DHAVE_CONFIG_H -I. -I../../src/ld -I. -D_GNU_SOURCE -I. -I../../src/ld -I../bfd -I../../src/ld/../bfd -I../../src/ld/../include -I../../src/ld/../intl -I../intl  -g -O2 -DLOCALEDIR="\"/usr/share/locale\""   -W -Wall -Wstrict-prototypes -Wmissing-prototypes -g -O2 -c ldlex.c
lex.yy.c:3465: warning: no previous prototype for `yyget_lineno'
lex.yy.c:3474: warning: no previous prototype for `yyget_in'
lex.yy.c:3482: warning: no previous prototype for `yyget_out'
lex.yy.c:3490: warning: no previous prototype for `yyget_leng'
lex.yy.c:3499: warning: no previous prototype for `yyget_text'
lex.yy.c:3508: warning: no previous prototype for `yyset_lineno'
lex.yy.c:3520: warning: no previous prototype for `yyset_in'
lex.yy.c:3525: warning: no previous prototype for `yyset_out'
lex.yy.c:3530: warning: no previous prototype for `yyget_debug'
lex.yy.c:3535: warning: no previous prototype for `yyset_debug'
lex.yy.c:3541: warning: no previous prototype for `yylex_destroy'
../../src/ld/ldlex.l: In function `yy_input':
../../src/ld/ldlex.l:615: `yy_current_buffer' undeclared (first use in this function)
../../src/ld/ldlex.l:615: (Each undeclared identifier is reported only once
../../src/ld/ldlex.l:615: for each function it appears in.)
/usr/include/sys/stat.h: At top level:
lex.yy.c:2973: warning: `yyunput' defined but not used
make[4]: *** [ldlex.o] Error 1

It looks like an incompatibility between this version of binutils and
the version of flex in sid, which is 2.5.31-3.  Am I missing something
or can this just not be built at the moment?

I had no more luck trying to build a cross gcc from source without
tpkg-make -- more on that in a minute.

Any help would be enormously appreciated.

-- 
Martin 

