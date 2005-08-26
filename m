From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 26 Aug 2005 23:05:50 +0000
Subject: Re:[PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES
Message-Id: <Pine.LNX.4.62.0508261559450.17433@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508262246.j7QMkEoT013490@linux.jf.intel.com>
In-Reply-To: <200508262246.j7QMkEoT013490@linux.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Lynch <rusty.lynch@intel.com>
Cc: linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com

On Fri, 26 Aug 2005, Rusty Lynch wrote:

> Just to be sure everyone understands the overhead involved, kprobes only 
> registers a single notifier.  If kprobes is disabled (CONFIG_KPROBES is
> off) then the overhead on a page fault is the overhead to execute an empty
> notifier chain.

Its the overhead of using registers to pass parameters, performing a 
function call that does nothing etc. A waste of computing resources. All 
of that unconditionally in a performance critical execution path that 
is executed a gazillion times for an optional feature that I frankly 
find not useful at all and that is disabled by default.
