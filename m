From: Andrew Morton <akpm@osdl.org>
Date: Mon, 22 Mar 2004 10:15:55 +0000
Subject: testing a new syscall
Message-Id: <20040322021555.7b6f9317.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I'm trying to work out how to test the new remap_file_pages() syscall on
ia64 and have conceded defeat.

I got this far, but it segfaults:

#elif __ia64__
#define __NR_sys_remap_file_pages 1259
...
_syscall5(long, sys_remap_file_pages, unsigned long, start, unsigned long, len,
        unsigned long, prot, unsigned long, pgoff, int, flags);

....

#if defined(__ia64__)

asm(
"	.text\n"
"	.global __ia64_syscall#;\n"
"	.align	32;\n"
"	.proc	__ia64_syscall#;\n"
"__ia64_syscall#:\n"
"	.regstk 6,0,0,0\n"
"	mov r15=in5\n"
"	break 0x100000\n"
"	movl r2=errno\n"
"	cmp.eq p6,p7=-1,r10\n"
"	;;\n"
"(p6)	st4 [r2]=r8\n"
"(p6)	mov r8=-1\n"
"	br.ret.sptk.many rp\n"
"	.endp	__ia64_syscall#\n"
);

#endif


What's the magic here?

Thanks.
