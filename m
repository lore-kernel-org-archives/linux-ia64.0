From: David Gibson <david@gibson.dropbear.id.au>
Date: Wed, 22 Feb 2006 02:17:14 +0000
Subject: Re: IA64 non-contiguous memory space bugs
Message-Id: <20060222021714.GD23574@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060222001359.GA23574@localhost.localdomain> <20060221.163935.32626284.davem@davemloft.net>
In-Reply-To: <20060221.163935.32626284.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 21, 2006 at 04:39:35PM -0800, David S. Miller wrote:
> From: David Gibson <david@gibson.dropbear.id.au>
> Date: Wed, 22 Feb 2006 11:13:59 +1100
> 
> > Quite some time ago, I found (by inspection) an ia64 specific bug
> > related to its non-contiguous user address space.  I've never done
> > anything about it, because I don't have an ia64 to test on - but
> > somebody should fix it.  Recently I've spotted another possible bug,
> > also by inspection - I don't know enough about ia64 to tell if it's a
> > real problem or not.
> 
> Good catch David, I'll need to add similar checks on sparc64 as
> we have a 64-bit virtual address space hole on several processors
> there.

Ok, that patch adds all the checks in generic code anyway, so all you
should need for sparc64 is an appropriate REGION_MAX() macro.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
