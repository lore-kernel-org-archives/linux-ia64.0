From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 17 Jan 2004 17:06:47 +0000
Subject: Re: [PATCH] fix cast in irq_lsapic.c
Message-Id: <20040117170647.A5014@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040116201522.GA15454@sgi.com>
In-Reply-To: <20040116201522.GA15454@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 16, 2004 at 12:15:22PM -0800, Jesse Barnes wrote:
> Now that I've disabled dependency violation checking in my build of
> binutils, I can see real warnings much more easily.
> 
> This patch just updates the cast in irq_lsapic.c to use the cpumask_t
> type for the noop cast assignment to smp_affinity.

I think Jack already sent a patch for this when we were in freeze and
the same comment applies here:  I think the method is optional, so you
can probably just remove it, if not please add a properly prototyped
stub function for it.

