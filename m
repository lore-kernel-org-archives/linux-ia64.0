From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 07 Mar 2005 19:04:04 +0000
Subject: Re: need ia64 testers: no per-arch mem_map init
Message-Id: <200503071104.04733.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109981490.1976.17.camel@localhost>
In-Reply-To: <1109981490.1976.17.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, March 4, 2005 6:04 pm, Jesse Barnes wrote:
> > However, ia64 has perhaps the most complex mem_map[ initialization, and
> > a diverse set of configurations.  I'd much prefer to fix any corner
> > cases now, than try to fix it up after it's in -mm.  I'd appreciate all
> > of the ia64 testing I can get, especially when CONFIG_NUMA is on.
>
> Sure, I'll test this on some Altix platforms (I'll try to find a big one),
> but I might not get to it until next Monday.

Boots fine on a 28 node Altix system.

Jesse
