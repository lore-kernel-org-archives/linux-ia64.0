From: Keith Owens <kaos@sgi.com>
Date: Sun, 02 Mar 2003 05:15:47 +0000
Subject: Re: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805882@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805882@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 20 Feb 2003 12:29:20 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>>The patch basically looks fine to me, except that I'd really like to
>>prefer to have it split up into one patch that does the pt_regs fixes
>>and one that does the debug enhancements.  And while you're at it,
>>please use something a bit more concise than UNW_DEBUG_PRINT
>>(something like DPRINT or UNW_DPRINT should be sufficient).
>
>Two patches follow.  The first updates include/asm-ia64/unwind.h,
>arch/ia64/kernel/unwind_i.h, arch/ia64/kernel/unwind.c to handle
>multiple pt_regs on stack.  The second only updates unwind.c, it goes
>over the first patch to clean up the debug code, using UNW_DPRINT().

This patch was not included in the ia64 bundle for 2.4.21-pre5.  Are
there any problems with the patch?  Do I need to send it again?  It
applies over 2.4.21-pre5 with a 2 line offset on the last hunk.


