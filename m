From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 09 Oct 2003 17:28:01 +0000
Subject: RE: wrong initial ia64_kr(current_stack) value
Message-Id: <marc-linux-ia64-106572059504156@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106571413927132@msgid-missing>
In-Reply-To: <marc-linux-ia64-106571413927132@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just to clarify, 2.4.22 has a back port of non-identity mapped kernel
that touches the same area in head.S.  It happens that the port also fix
the bug described below. So 2.4.21 and older are affected.

- Ken


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Chen, Kenneth W
Sent: Thursday, October 09, 2003 8:37 AM
To: linux-ia64@vger.kernel.org
Subject: wrong initial ia64_kr(current_stack) value


We start seeing random kernel hang at fairly late stage of booting when
lots of processes are spawned by the init script.  The kernel used is a
variant of 2.4.21.  At the time of the hang, one CPU is stuck in page
fault handler with no apparent valid dtlb mapping for the kernel stack.
Interesting enough, the task that the stuck CPU is executing has its
kernel stack allocated out of 16-32MB physical memory range (we are
using 16MB kernel granule in this exercise).  We finally tracked it down
to be a bug in _start() where IA64_KR(CURRENT_STACK) was incorrectly
initialized.

This code in head.S is wrong:
 
    mov r16=KERNEL_TR_PAGE_NUM
    ;;

    // load the "current" pointer (r13) and ar.k6 with the current task
    mov r13=r2
    mov IA64_KR(CURRENT)=r3         // Physical address

    // initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
    mov IA64_KR(CURRENT_STACK)=r16


r16 is loaded with the kernel page number measured in
(1<<KERNEL_TR_PAGE_SHIFT) pages, but the check in ia64_switch_to()
expects it to be in (1<<IA64_GRANULE_SHIFT) units.  When granule size is
16MB, we can hit a problem if the task structure area (the 2 pages
allocated for task_stuct and kernel stack area) of the first process
that we switch out of idle is in the physical address range [16MB,32MB],
as the check in ia64_switch_to() will mistakenly think that we already
have this mapping loaded in dtr[2] but actually it doesn't.

The hang will end up with nested TLB fault where secondary DTLB miss for
the kernel stack will never complete.  The mishap is due to
initialization code using the wrong page size when computing the initial
value for the "safe" page number that was stored in a kernel register
marking which address was mapped for the stack.  ia64_switch_to is
really confused on which page is mapped in DTR when coming out of idle,
because someone lied to him.

I'm surprised that this bug has gone underground for so long.  It could
happen on any SMP system out there, but it is easier for the bug to bite
on a system with lots of CPUs.  Here is a patch that fixed problem.
Kudos to Tony Luck, Kimi Suganuma and Nomura-san for helping me track
this down.

- Ken

p.s. only 2.4.x kernel has this bug.

