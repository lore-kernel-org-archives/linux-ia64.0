From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 03 Mar 2003 16:47:49 +0000
Subject: Re: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805882@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805882@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >Two patches follow.  The first updates include/asm-ia64/unwind.h,
> >arch/ia64/kernel/unwind_i.h, arch/ia64/kernel/unwind.c to handle
> >multiple pt_regs on stack.  The second only updates unwind.c, it goes
> >over the first patch to clean up the debug code, using UNW_DPRINT().
> 
> This patch was not included in the ia64 bundle for 2.4.21-pre5.  Are
> there any problems with the patch?  Do I need to send it again?  It
> applies over 2.4.21-pre5 with a 2 line offset on the last hunk.

Wow, somebody is actually looking at the BK tree :-)

Your patches are still in my "todo" list.  I haven't looked at it
closely, but my intent is to put it in before the real 2.4.21 patch.

Bjorn


