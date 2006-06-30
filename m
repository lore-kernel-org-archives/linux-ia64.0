From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 30 Jun 2006 10:24:35 +0000
Subject: Re: perfmon2 vector argument question
Message-Id: <20060630102435.GA21819@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060619204012.GE26378@frankl.hpl.hp.com> <20060628201708.08af034c.akpm@osdl.org>
In-Reply-To: <20060628201708.08af034c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, perfmon@napali.hpl.hp.com

Andrew,

On Wed, Jun 28, 2006 at 08:17:08PM -0700, Andrew Morton wrote:
> > 
> > Does someone have something else to propose?
> > 
> > If not, what is your opinion of the two approaches above?
> > 
> 
> The first approach should be fine - we do that in lots of places, such as
> in core_sys_select().
> 
Ok, that's good to know. I looked at the stack consumption on x86 and it
is comparable to what you do for core_sys_select().

> Applications mut be calling this thing at a heck of a rate for kfree()
> overhead to matter.  I trust CONFIG_DEBUG_SLAB wasn't turned on...

That was using a micro-benchmark to stress certain paths in perfmon.
CONFIG_DEBUG_SLAB was not turned on.

Thanks.

-- 
-Stephane
