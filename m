From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Feb 2008 16:38:59 +0000
Subject: Re: [PATCH] Reduce per_cpu allocations to the minimum needed for
Message-Id: <20080213163859.GA23324@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080211175918.GO3875@sgi.com>
In-Reply-To: <20080211175918.GO3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph,

If you point me at that patch, I would happily resurrect it and see if
I can get it worked in.  I will be working on that in the evenings so
my progress will be slow.

Thanks,
Robin

On Tue, Feb 12, 2008 at 10:53:41AM -0800, Christoph Lameter wrote:
> On Tue, 12 Feb 2008, Robin Holt wrote:
> 
> > Please don't apply this yet.  I just noticed the CONFIG_FLATMEM configs
> > did not work.  I will look at this more this evening.
> 
> That reminds me: I have a patch to remove all other memory models except 
> for SPARSE_VMEMMAP for ia64 somewhere.... If we would merge that then 
> maintaining ia64 may become simpler.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
