From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 05 Mar 2005 02:04:21 +0000
Subject: Re: need ia64 testers: no per-arch mem_map init
Message-Id: <200503041804.21403.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109981490.1976.17.camel@localhost>
In-Reply-To: <1109981490.1976.17.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, March 4, 2005 4:11 pm, Dave Hansen wrote:
> I've sent this to some of you ia64 folks before, but this has changed
> slightly.  I'd like to send this to Andrew Morton for inclusion in -mm
> in the next couple of days if everything goes OK.  Bob Picco noticed
> that it didn't work because of an oversight of mine with how vmem_map
> works, but I think that's fixed now.
>
> In any case, this simplifies how all architectures set up the global
> mem_map variable, and will help simplify interactions with the memory
> hotplug code as well.
>
> However, ia64 has perhaps the most complex mem_map[ initialization, and
> a diverse set of configurations.  I'd much prefer to fix any corner
> cases now, than try to fix it up after it's in -mm.  I'd appreciate all
> of the ia64 testing I can get, especially when CONFIG_NUMA is on.

Sure, I'll test this on some Altix platforms (I'll try to find a big one), but 
I might not get to it until next Monday.

Thanks,
Jesse
