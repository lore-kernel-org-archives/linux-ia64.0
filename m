From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 May 2006 21:04:08 +0000
Subject: RE: [PATCH 2/3] swiotlb: create __alloc_bootmem_low_nopanic and add support in SWIOTLB
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0670403C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504205929.GD14361@us.ibm.com>
In-Reply-To: <20060504205929.GD14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>
Cc: Muli Ben-Yehuda <muli@il.ibm.com>, linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, mulix@mulix.org

> I "fixed" it with the hack below.  Please let me know if this is not
> palatable for you.

Not really.  The only use of platform_dma_init() that I can see is in
arch/ia64/mm/init.c:mem_init() ...

	platform_dma_init();

so "void" looks to be the right return value.  Why did it get changed to
be "int" (here's where I admit that I've only looked superficially at your
patch).

-Tony
