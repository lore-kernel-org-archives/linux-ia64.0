From: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
Date: Mon, 06 Jun 2005 17:36:52 +0000
Subject: [patch 0/3] Kprobes Ia64 more fixes....
Message-Id: <20050606173652.059047000@csdlinux-2.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, systemtap@sources.redhat.com, rusty.lynch@intel.com, davidm@napali.hpl.hp.com, alen.brunelle@hp.com, anil.s.keshavamurthy@intel.com

Hi All,
	Based on the feedback obtained from the community, I have
have address the below issues in the Kprobes.

1) When patching the original instruction with the break instruction,
we need to preserve the original qualifying predicate for all instruction
except for some special instruction like
(qp) cmp.crel.ctype p1,p2=r1,r2
where ctype = unc, which always needs to be emulated irrespective of
original qp.

2) Fail register_kprobes() for unsupported instruction. Currently
Kprobes of some speculation chk instruction and mov r1=ip 
kind of instructions are not supported. Hence when user
tries to register kprobes on these instruction, fail register_kprobe()
instead of handling badly.

Comments welcome.

Thanks,
Anil Keshavamurthy
--

