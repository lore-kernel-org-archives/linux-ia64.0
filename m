From: Matthew Wilcox <willy@debian.org>
Date: Wed, 08 Sep 2004 22:03:23 +0000
Subject: Re: [PATCH] general config option cleanup
Message-Id: <20040908220323.GP642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409081447.38703.jbarnes@engr.sgi.com>
In-Reply-To: <200409081447.38703.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 08, 2004 at 02:47:38PM -0700, Jesse Barnes wrote:
> As threatened, here's a patch that unifies the ia64 memory init and memmap 
> codepaths by unconditionalizing the CONFIG_VIRTUAL_MEM_MAP code and making 
> CONFIG_DISCONTIGMEM required.  It also allows building with CONFIG_SMP=n 
> and/or CONFIG_NUMA=n.  The end result should be easier to understand and hack 
> on, and should make things like memory hotplug that much easier since people 
> will only have to worry about one code path instead of every combination of 
> the three options.

I don't really like this.  It penalises platforms like Intel's Tiger box
that have contiguous memory.  I'd really like to see VIRTUAL_MEM_MAP go
away and the DISCONTIGMEM code be usable for both zx1/sx1000 and sn2.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
