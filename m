From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 24 Feb 2006 02:46:44 +0000
Subject: Re: IA64 non-contiguous memory space bugs
Message-Id: <20060224024644.GD28368@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060224001146.GC25101@localhost.localdomain> <200602240114.k1O1E4g05231@unix-os.sc.intel.com>
In-Reply-To: <200602240114.k1O1E4g05231@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2006 at 05:14:03PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Thursday, February 23, 2006 4:12 PM
> > It doesn't really mean different things - "touches a hugepage
> > exclusive area" is the correct semantic, the ia64 implementation
> > doesn't quite encode that, but is equivalent for valid address
> > ranges.  (though I wonder if that's another bug associated with by
> > task-region-max patch, without that patch invalid address ranges can
> > slip through, so maybe it's possible on ia64 to create a normalpage VM
> > with its start in the address space gap and its end in the hugepage
> > region, ouch).
> 
> This is getting complicated that my little brain hurts.  There has been
> so many iterations that the semantic is ambiguous.  If the semantic is
> decided to be "overlap", then 

The semantic is "! is this range ok for a normalpage VMA", so that we
can do that check on the MAP_FIXED path.  That implies "overlap" -
except that if you assume it's passed a valid user address range in
the first place, then just checking the region is sufficient on ia64.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
