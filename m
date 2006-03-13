From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 13 Mar 2006 16:31:25 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <Pine.LNX.4.64.0603130827550.9881@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Mar 2006, Zoltan Menyhart wrote:

> I think we can do some accessed/dirty bit handler tuning. E.g.
> in my patch (based on the Christoph's one entitled "Fix race in the
> accessed/dirty bit handlers"), I think we gain a bit by:

Could you measure the effect that this has? We seem to be getting into 
some special processor behavior here.
 
> - using the "nta" hint in order not to "pollute" the caches L1D / L3

The last that I heard about nta was that it just skips the marking of a 
cacheline as recent. Thus the cacheline will be a more likely candidate to 
be evicted from the caches. Are you sure that the processors can bypass 
the L1D and L3?

