From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 28 Apr 2001 03:20:00 +0000
Subject: Re: [Linux-ia64] Cleanup include/asm-ia64/offsets.h
Message-Id: <marc-linux-ia64-105590693005488@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Apr 2001 19:55:57 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Sat, 28 Apr 2001 12:49:29 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> As part of my makefile rewrite for 2.5 I am cleaning up
>  Keith> problems like this.  The patch below deletes
>  Keith> include/asm-ia64/offsets.h from the shipped tree, restricts
>  Keith> its use to assembler code only and makes sure that assembler
>  Keith> code always gets the latest offset values.  C code is not a
>  Keith> problem, the dependency system handles structure and config
>  Keith> changes for C code.
>
>There is no way I'm going to duplicate those definitions for asm and C
>code.  Please find a way to make the same file work for both C and
>asm.

Duplication is unavoidable.  I could add lines like this to ptrace.h

#ifndef __ASSEMBLY__
#define IA64_SWITCH_STACK_AR_UNAT_OFFSET (offsetof(struct switch_stack, ar_unat))
#define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET (offsetof(struct switch_stack, ar_bspstore))
#endif

and to other C include files but it is still duplication, just moved
from .c files to a .h file.

Assembler is restricted in what it can include or uses the values in
pre-processor context where sizeof() does not work so it needs the
generated offsets.  But generating offset.h breaks the kernel
dependency system so it needs explicit dependency information when
offsets.h is used.  The only way to do that cleanly is to restrict its
use to assembler code.


