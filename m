From: Martin Pool <mbp@samba.org>
Date: Mon, 28 Apr 2003 06:39:40 +0000
Subject: Re: [Linux-ia64] building an ia64 cross toolchain on debian?
Message-Id: <marc-linux-ia64-105590723705613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 28 Apr 2003, Martin Pool <mbp@samba.org> wrote:
> ../../src/ld/ldlex.l: In function `yy_input':
> ../../src/ld/ldlex.l:615: `yy_current_buffer' undeclared (first use in this function)
> ../../src/ld/ldlex.l:615: (Each undeclared identifier is reported only once
> ../../src/ld/ldlex.l:615: for each function it appears in.)
> /usr/include/sys/stat.h: At top level:
> lex.yy.c:2973: warning: `yyunput' defined but not used
> make[4]: *** [ldlex.o] Error 1

I tried rolling flex back to the version from Stable, 2.5.4a-24, and
this allowed the build to complete.  It looks like ld's lexer was
using an undocumented interface to flex, so it's not really flex's
fault that it broke.  

Should I report this as a bug against toolchain-source or flex?  I
suppose flex just got too far ahead of gcc as packaged in
toolchain-source?

-- 
Martin 

