From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Nov 2005 23:24:00 +0000
Subject: RE: [PATCH] - Make pfn_valid more precise for SGI Altix systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EADDE0@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051109202506.GA4152@sgi.com>
In-Reply-To: <20051109202506.GA4152@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like the existing pfn_valid() returns bogus values on
platforms where memory doesn't start at 0x0 (which is essentially
all ia64 platforms as even those with memory at 0x0 usually can't
use it because of cacheing issues with providing a WB mapping for
the VGA mem at 0xc0000).

-# define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))

There's another pfn_valid() definition a few lines earlier
in this file for the CONFIG_FLATMEM case.  Does it need
this treatment too?  I'd guess not as Altix is far from flat.

Yet another pfn_valid() in linux/mmzone.h (for CONFIG_SPARSEMEM).
That one does table lookups ... presumably also safe.

-Tony
