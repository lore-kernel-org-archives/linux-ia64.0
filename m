From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 19 Aug 2005 05:02:49 +0000
Subject: minor ia64_leave_syscall bug
Message-Id: <20050819050249.GA3069@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed something strange about the ia64_leave_syscall path,
though I guess it only affects performance monitoring in the
presence of kernel syscalls, and hence is not very serious.

r22 seems to be cleared before being consumed:

ia64_leave_syscall:
735:  (pKStk) mov r22=psr             // M2 read PSR now that interrupts are disabled
756:          mov r22=r0              // clear r22
768:  (pKStk) br.cond.dpnt.many skip_rbs_switch
skip_rbs_switch:
1045: (pKStk) extr.u r22=r22,21,1     // I0 extract current value of psr.pp from r22

Perhaps the mov r22=r0 should be predicated with (pUStk)?

Matt

