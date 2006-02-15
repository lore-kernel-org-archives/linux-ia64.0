From: Jack Steiner <steiner@sgi.com>
Date: Wed, 15 Feb 2006 15:08:23 +0000
Subject: Re: [PATCH] ia64: simplify and fix udelay()
Message-Id: <20060215150823.GA27208@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214184017.20492.48141.sendpatchset@tomahawk.engr.sgi.com> <200602150908.k1F98dg02934@unix-os.sc.intel.com>
In-Reply-To: <200602150908.k1F98dg02934@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Robin Holt <holt@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Jes Sorensen <jes@sgi.com>

On Wed, Feb 15, 2006 at 01:08:41AM -0800, Chen, Kenneth W wrote:
> hawkes@sgi.com wrote on Tuesday, February 14, 2006 10:40 AM
> > a preemption and migration to another CPU during the
> > while-loop
> 
> Off topic from the subject line a bit, but related: how many Altix
> SN2 customers in the field turn on CONFIG_PREEMPT? Redhat EL4 doesn't
> turn on preempt, SuSE SLES9 and SLES10 beta don't turn it on either.
> Is there a real benefit of turning that option on for SN2?

AFAICT, no one at SGI uses or plans to use CONFIG_PREEMPT. Most of
our customers use kernels from one of the distros & none at this point
enables preemption. 

The realtime folks here have experimented with CONFIG_PREEMPT but so
far have not seen any significant benefit.

Regardless, we should fix udelay() to handle unsync'ed ITCs.  It would
be nice to have it working.



-- Jack

