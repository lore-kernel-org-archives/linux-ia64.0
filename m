From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Oct 2005 19:00:46 +0000
Subject: RE: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D01944@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Your build must be against -mm because pfn_to_kaddr shouldn't be required
>in 2.6.14.  The patch below will fix this.

I was building 2.6.14+(all the bits in Linus' git tree that I pulled
at about 8:30 PST today).  Presumably this bit has already been moved
from -mm to -linus?

Thanks for the patch, I'll give it a spin.

-Tony
