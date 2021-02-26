From: Chris Down <chris@chrisdown.name>
Date: Fri, 26 Feb 2021 13:47:20 +0000
Subject: Re: [PATCH] ia64: Depend on non-static printk for cmpxchg debug
Message-Id: <YDj76FjQCL7YgQq+@chrisdown.name>
List-Id: <linux-ia64.vger.kernel.org>
References: <YCflN5zTvo5mxvKY@chrisdown.name>
 <YDjt/lI82VzZcCgq@chrisdown.name>
 <20210226130029.GC2723601@casper.infradead.org>
 <YDj0T7H4ZbuEAYwK@chrisdown.name>
In-Reply-To: <YDj0T7H4ZbuEAYwK@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Chris Down writes:
>I must confess I have no idea of the history of why it was `extern 
>int` in the first place -- my fear was somehow we use cmpxchg.h from a 
>different context.  Do you have any idea? :-)

Ok, found where it's introduced in the pre-git archives: "New file 
asm-ia64/intrinsics.h." from David Mosberger <davidm@tiger.hpl.hp.com>, Dec 9 
2002. No indication why it's extern, but it's been there since the dawn of 
ia64.
