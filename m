From: Jack Steiner <steiner@sgi.com>
Date: Wed, 25 Jan 2006 19:43:26 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125194326.GA19238@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 25, 2006 at 01:15:49PM -0600, Brent Casavant wrote:
> On Wed, 25 Jan 2006, Chen, Kenneth W wrote:
> 
> > I suppose, I don't have strong opinion where it is being called.
> > Adding to ia64_load_extra(), you might need #ifdef CONFIG_SMP, of
> > course you can just sneak in a plain version unless people yell at
> > you for slowing their UP performance (I won't yell at you for UP).


When the dust settles on this patch, I'd like to investigate whether the TLB
flushing that is done on SN platforms via the scheduler migration callout in
set_cpus_allowed() (see tlb_migrate_finish()) could be done using your
new mechanism.  Your new mechanism looks better suited to do what is required
& will result in better performance.

Note that I'm NOT suggesting that tlb_migrate_finish() can be
used for what you need - it is called only on explicit user migrations
via set_cpus_allowed().


-- 
Jack
