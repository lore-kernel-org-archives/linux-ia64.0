From: Weihaw CHUANG <wchuang@cs.ucsd.edu>
Date: Thu, 03 May 2001 23:51:16 +0000
Subject: [Linux-ia64] location of statcked registers after exception
Message-Id: <marc-linux-ia64-105590693005533@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I'm using the ptrace interface to single step a program (David Mosberger's
utrace.c that he posted recently).  Through this I'm able to get much of
the user register space.  However I'm having problems getting stacked
registers.

From what I understand and please correct me where I'm wrong, stacked
registers are "cover"'ed after interrupt (in this case single step
exception) and are pushed onto the memory stack.  Through ptrace I can get
access to that memory as follows:

Assume that int cfm_sof contains CFM.sof, and regid is the GR register
number, ie R32 is regid2

  int offset = cfm.sof - (regid-32)
  unsigned long long = ptrace(PTRACED_PEEKUSER, pid, PT_AR_BSP, 0);
  regvalue = ptrace(PTRACE_PEEKDATA, pid, 
                    (long ) ia64_rse_skip_regs((long*) bsp, offset), 0);



That is, does this diagram make sense? 

alloc r35 = ar.pfs, 0, 3, 0, 0
reg stack
   | r32    | r34      | r35    |   (r35 is top of reg stack)
negative offset from bsp is:
     3        2          1        bsp

Many thanks,
-Wei



