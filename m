From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 04 Apr 2006 13:30:34 +0000
Subject: RE: Fix ia64 bit ops: Full barriers for bit operations returning a value
Message-Id: <200604041329.k34DTRx03774@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Monday, April 03, 2006 7:12 PM
> On Mon, 3 Apr 2006, Chen, Kenneth W wrote:
> 
> > Looks good to me.
> > Acked-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> Ummm.. Are you sure? The release should come before the acquire. The 
> final store of the cmpxchg may be delayed until after stores following
> the cmpxchg?

I realized that.  However, this patch is one step forward to fix current
deficiency even if it is not a full solution.  Hence the ack. I also take
that as your intention to post this patch as well, no?

- Ken
