From: "R. Lake" <rich@lakes.plus.com>
Date: Thu, 16 Oct 2003 22:51:16 +0000
Subject: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106634477003880@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm investigating a means of emulating causes of SEGV where they can be
isolated from genuine failure. For example, a rule stating a load from
address 0x100 "loads" the value 42 into the target register.

A simple test to decode the instruction, locate and modify the operand
register in the sigcontext or backing store, then increment sc_ip shows the
expected behaviour. But, for practical usage I'm not entirely confident I've
taken all the necessary steps to return to the kernel in a robust manner.
I've thus far taken insight from the unaligned handler albeit without
altering the psr.ri field. So, my question is... am I missing a vital stage
to this process, some piece of information the kernel expects to receive
when avoiding the faulting instruction?

Regards,
Richard.



