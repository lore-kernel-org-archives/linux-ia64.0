From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 15 Nov 2000 20:02:30 +0000
Subject: Re: [Linux-ia64] Problem compiling latest gcc (001024 snapshot)
Message-Id: <marc-linux-ia64-105590678205727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205721@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205721@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>../../gcc/config/ia64/lib1funcs.asm:655: Error: Unknown opcode `mov.ret.sptk

Somehow gcc accidentally used an out-of-date assembler.

>/usr/src/RPM/BUILD/src/builddir/gcc/xgcc -B/usr/src/RPM/BUILD/src/builddir/gcc/
>-B/usr/ia64-mandrake-linux/bin/ -I/usr/ia64-mandrake-linux/include -O2

The -B options here are in the wrong order.  If you have an old assembler in
/usr/ia64-mandrake-linux/bin/, then gcc will accidentally use this old
assembler instead of the new assembler in /usr/src/.../builddir/gcc.
This can be fixed by doing a "make install-gas" as Jes suggested, or by
renaming the old /usr/ia64-mandrake-linux tree to move it out of the way as
Bill suggested.

We've had a lot of problems with ordering of these -B options.  It has been
broken and fixed several times this year.  The current stable compiler I am
maintaining was made from a FSF gcc snapshot when this was broken.  This
is only a problem when there is an ABI change though, so hopefully you only
have to deal with this once.

>Oh, and BTW, .033 is unreadable, it's 600 on the FTP site.

Fixed.

Jim

