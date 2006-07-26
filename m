From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 26 Jul 2006 15:33:35 +0000
Subject: RE: [Patch] Don't alloc empty frame in ia64_switch_mode_phys
Message-Id: <000001c6b0c8$e0f3a710$6154e984@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1153870600.3286.72.camel@linux-znh>
In-Reply-To: <1153870600.3286.72.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote on Tuesday, July 25, 2006 4:37 PM
> I think ia64_switch_mode_phys and ia64_switch_mode_virt 
> does not need to alloc an empty frame. 
> An empty frame is required by loadrs but flushrs 
> does not need that.

This patch would make your previous "Do not assume output registers
be reservered" unnecessary, isn't it?  It will automatically solve
the problem you are trying to fix in previous patch.

The real issue to me is that ia64_switch_mode_phys() creates a zero
stack frame before turning off interrupt.  If the zero frame alloc
instruction is removed, the current register stack frame ought to be
safe because they should be preserved by the interrupt return path.


- Ken
