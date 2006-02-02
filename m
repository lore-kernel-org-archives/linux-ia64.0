From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Feb 2006 21:50:46 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <20060202215045.GA7760@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 02, 2006 at 01:46:05PM -0800, Luck, Tony wrote:
> > Jack, I think this is the thread you are looking for:
> >    http://marc.theaimsgroup.com/?l=linux-ia64&m2422250517703&w=2
> 
> The current state of the tree is that Andrew added the patch
> to make the definition of printk_clock() in kernel/printk.c
> "__attribute__((weak))" so that architectures could override
> with their own version.  Default version uses sched_clock().
> 
> So far we haven't made use of this ... but we need to do it (partly
> because it crashes early on Altix, but also because it returns
> meaningless values on any system where the clocks are not synched
> on different cpus (perhaps just Altix).
> 
> -Tony

Do you understand why it crashes only on Altix?? It looked to
me that all IA64 platforms would crash but obviously I'm wrong.
What did I miss...

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


