From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 18:58:27 +0000
Subject: RE: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <200602241858.k1OIwSg15658@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian Hildner wrote on Friday, February 24, 2006 2:08 AM
> self-modifing code isn't the straight forward way of programming. So 
> wouldn't it be an idea to let the code crash instead of silently work 
> with a potentially wrong number of registers here, if by any reason the 
> patch mechanism doesn't work.

This argument is very biased.  A bug is a bug, regardless where the
origin or through which mechanism.  Programming error like wrongly
initialize a value has the same severity compare to patching wrong code.
It's just way too biased to say bug in patching mechanism is more sever
than any other buggy code.

Plus, self-modifying code in the kernel is everywhere: look at the core
of the core kernel:

(1) low level vhpt handlers: vhpt_miss and nested_dtlb_miss
(2) fsyscall table
(3) fsys bubble down
(4) mckinley_e9

All does instruction patching.  I don't suppose you would recommend all
instances listed above to be changed?


> I suppose the usage of a break instruction 
> (with non_syscall number) to indicate failing/missing patch here. That 
> would add another level of security here.

This argument is equally flawed.  If you don't have any trust in patching
mechanism in previous argument, why would you trust that patch out a break
instruction is going to be any better?

- Ken

