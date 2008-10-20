From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:19 +0000
Subject: [PATCH 00/35] cpumask: Replace cpumask_t with struct cpumask
Message-Id: <20081020170319.539427000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org


Redesign cpumask API to explicitly declare struct cpumask pointers to
the cpumask_* operators and add functions to make it easier to support
struct cpumask pointers on the stack.

This patchset supplies the infrastructure going forward to implement
this new struct cpumask API.  Patches have been written and tested
to verify the functionality of this API.  These are still in review
between Rusty and myself.

Question: what's the status of the sparse-irqs?  (I have two patches
to replace the static cpumask fields in the irq_desc and irq_cfg
arrays which depend on sparse irqs.)


Compiled and tested on x86_64.

Based on tip/master @ v2.6.27-5807-g03da394

-- 
