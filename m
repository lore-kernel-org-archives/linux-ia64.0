From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 12:09:04 +0000
Subject: Re: [PATCH] ia64: export cpu_core_map
Message-Id: <20080729120904.GC10501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729111225.GA10471@solarflare.com>
In-Reply-To: <20080729111225.GA10471@solarflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2008 at 12:12:26PM +0100, Ben Hutchings wrote:
> cpu_core_map is referenced by the topology_core_siblings() macro, which is
> now used by the sfc driver.  Matthew Wilcox reported that the driver failed
> to link because that symbol is not exported.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> I have not yet tested this as we have limited ia64 kit here.  Matthew,
> please could you check that this builds at least?

I had tested it last night when I CC'd you on the patch I sent to the
ia64 mailing list.

I have booted it on a bunch of different sn2 ia64 boxes, but none with
your sfc network adapter (whatever that is).  It does, however, build ;)

Thanks,
Robin
