From: Robin Holt <holt@sgi.com>
Date: Fri, 11 Nov 2005 17:48:58 +0000
Subject: Re: [Patch 1/1] 4-level page tables v5.
Message-Id: <20051111174858.GE14968@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051111153543.GC19382@lnx-holt.americas.sgi.com>
In-Reply-To: <20051111153543.GC19382@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It was pointed out that the latest submission doesn't have
any comment about what is different.

This version applies Ken's suggestion directly to the original
ivt.S.  There is one minor change from Ken's in that I retained
the use of #ifdef CONFIG_PGTABLE_4 where he was using (p9) to
just skip an instruction.

Sorry for the confusion,
Robin

On Fri, Nov 11, 2005 at 09:35:43AM -0600, Robin Holt wrote:
> 
> This patch introduces 4-level page tables to ia64.  I have run
> some benchmarks and found nothing interesting.  Performance has
> consistently fallen within the noise range.
> 
> It also introduces a config option (setting the default to 3
> levels).  The config option prevents having 4 level page
> tables with 64k base page size.
> 
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
