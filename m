From: Weihaw CHUANG <wchuang@cs.ucsd.edu>
Date: Fri, 04 May 2001 06:51:26 +0000
Subject: [Linux-ia64] Re: location of statcked registers after exception (superceeds previous email)
Message-Id: <marc-linux-ia64-105590693005534@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think I've figured out my own question.  However I still would like to
understand some of this kernel code in 
<linux src>/arch/ia64/kernel/entry.S

If my application takes an exception, what is the entry point in entry.S?
I'd also like to verify that application stacked registers  will be
stored on kernel stack during a context switch.  My understanding is that
only the last procedure frame will be stored there.  (Is this notion
correct?)

I'm still very unsure if my intuition is correct, hence the
questions.  I only figured out the below through trial and error
hacking.

Anyways the solution appears to be (again correct me if anything is brain 
damaged):

On Thu, 3 May 2001, Weihaw CHUANG wrote:

> 
>   int offset = cfm.sof - (regid-32)
>   unsigned long long = ptrace(PTRACED_PEEKUSER, pid, PT_AR_BSP, 0);
>   regvalue = ptrace(PTRACE_PEEKDATA, pid, 
>                     (long ) ia64_rse_skip_regs((long*) bsp, offset), 0);
> 

int offset = regid - 32;
unsigned long long bspstore = ptrace(PTRACED_PEEKUSER, pid,
                                    PT_AR_BSPSTORE, 0);
unsigned long long regvalue = ptrace(PTRACE_PEEKDATA, pid,
                     (long) ia64_rse_skip_regs((long*) bspstore, offset),
                     0);


I'd like to be pendantic, and make sure the following intuition is
correct.  Ptrace dumps seems to agree so far.

> 
> 
> That is, does this diagram make sense? 
> 
> alloc r35 = ar.pfs, 0, 3, 0, 0
> reg stack
>    | r32    | r34      | r35    |   (r35 is top of reg stack)
> negative offset from bsp is:
>      3        2          1        bsp
offset from 
     ^bspstore
       0        1          2

Thanks!!
-Wei


