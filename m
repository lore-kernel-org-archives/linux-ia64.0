From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 May 2005 22:03:29 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03915896@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
>it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
>be excessive 2^((50-28)+3 = 32Mb and not advised.

While you can tune a custom kernel for a particular system configuration,
we might have to use the 50/28 configuration for the generic "defconfig"
case ... that kernel should be bootable anywhere.   SGI needs (or will
need) the "50" for total physical size, and other platforms may need the
"28" (is that even small enough?  We currently have "granule" sizes of
16M and 64M to cope with odd holes in the physical address space ... so
perhaps the section size might need to be even smaller: 24 or 26?  How did
you come up with 28 as the low bound for SECTION_BITS?)

-Tony
