From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 04 May 2001 15:02:36 +0000
Subject: Re: [Linux-ia64] Re: location of statcked registers after exception (superceeds previous email)
Message-Id: <marc-linux-ia64-105590693005536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005534@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005534@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 May 2001 23:51:26 -0700 (PDT), Weihaw CHUANG <wchuang@cs.ucsd.edu> said:

  Weihaw> Anyways the solution appears to be (again correct me if
  Weihaw> anything is brain damaged):

Note that when using ptrace() to read PT_AR_BSP, you get a pointer to
the _end_ of the backing store, i.e., you get the value of ar.bsp as
if a "cover" instruction had been executed by the target task.  Since
the task is blocked at the time you call ptrace(), the stacked
registers are indeed on the stack (they get written to the
backingstore by the "flushrs" instruction in the context switch
routine).

Thus, to read stacked register, you'd do something along the lines of:

    unsigned long *rbs_end, *bsp;

    rbs_end = ptrace(PTRACED_PEEKUSER, pid, PT_AR_BSP, 0);
    bsp = ia64_rse_skip_regs(rbs_end, -cfm.sof);
    regvalue = ptrace(PTRACE_PEEKDATA, pid,
	              ia64_rse_skip_regs(bsp, regid - 32), 0);

(The code in utrace.c is outdated in this respect.)

	--david

