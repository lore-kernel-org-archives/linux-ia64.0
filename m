From: Grant Grundler <iod00d@hp.com>
Date: Wed, 11 Feb 2004 18:17:30 +0000
Subject: u64 vs %llu format
Message-Id: <20040211181730.GC10901@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David, et al,

Why is __u64 defined as "unsigned long" and not "unsigned long long"?

I ask because:
	u64 i;
	...
	printk("i %llu\n, i);

will generate this warning:
<file>:<line>: warning: long long unsigned int format, __u64 arg (arg 2)

The code is correct, but the warning is "wrong".
(It might be technically correct, but doesn't flag a problem).
ia64 compiler could equate "long long" and "long" types or
the kernel could define __u64 as "unsigned long long".

The code above could cast "(unsigned long long) i" but it seems
silly this would be necessary. Maybe that's the right (but ugly) way.
Or is there a different printk format the code should be using?

Survey of other arches shows several use "unsigned long" for __u64
and I'm wondering if someone knows how this issue was resolved
in those arches:
asm-alpha/types.h:typedef unsigned long __u64;
asm-ia64/types.h:typedef unsigned long __u64;
asm-mips/types.h:typedef unsigned long __u64;
asm-ppc64/types.h:typedef unsigned long __u64;
asm-s390/types.h:typedef unsigned long __u64;
asm-sparc64/types.h:typedef unsigned long __u64;

Note that parisc uses "unsigned long long" for both 32 and 64-bit kernels.

thanks,
grant
