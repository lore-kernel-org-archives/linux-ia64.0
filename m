From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Jan 2005 07:08:20 +0000
Subject: RE: [patch] per cpu MCA/INIT fixes.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A67B7B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>PERCPU_MCA_SIZE doesn't look likely to be a power of two, so using it
>as the 'align' argument to __alloc_bootmem trips the BUG at 
>mm/bootmem.c:158

When I "s/PERCPU_MCA_SIZE/PAGE_SIZE/", the tiger_defconfig kernel
boots quite nicely.

I'm too tired to look at what the alignment requirements for this
allocation are right now ... probably just "sizeof (long)"?

-Tony
