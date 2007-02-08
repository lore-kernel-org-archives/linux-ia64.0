From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Feb 2007 18:03:54 +0000
Subject: RE: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <617E1C2C70743745A92448908E030B2A011AC05D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Summarizing thread that I was sleeping through:

1) Use ar.kr2 for ...
No ... as Keith pointed out there is debug code in ivt.S to use
it to track the last few traps, and if that isn't being used it
is very handy for other debugging uses.  I won't give up the last
of these registers unless it is for some cause which is a clear and
obvious major win in performance or functionality.  An allegedly
faster way to find the cpu number is not a clear win (if the
percpu variable is in cache, then it is clearly faster to read
from memory).

2) Use ar.kr3 for cpu number, and then make the MCA code index an
array to get the phys address of the per-cpu area.
Messes with a lot of MCA code, and for a microscopic improvement
over my proposed getcpu() code.  Yes, you can avoid ever doing the system
call ... but only running the system call when you have migrated to a
different cpu should cover most calls [possible exception ... a future
scheduler might frequently move a process between logical cpus that
share all cache levels, since there is no cache penalty for running
on other cpus in the same cache domain].  So I'm not looking favourably
at this option at the moment ... but could change my mind if presented
with some data on getcpu() usage.

-Tony
