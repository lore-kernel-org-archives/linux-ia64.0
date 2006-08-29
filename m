From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Aug 2006 21:06:09 +0000
Subject: RE: [RFC][PATCH 10/10] convert the "easy" architectures to generic PAGE_SIZE
Message-Id: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201941.38D6254C@localhost.localdomain>
In-Reply-To: <20060829201941.38D6254C@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org

> Note that, as promised, this removes ARCH_GENERIC_PAGE_SIZE
> introduced by the first patch in this series.  It is no longer
> needed as _all_ architectures now use this infrastructure.

Either I goofed when applying these patches, or you missed one
in mm/Kconfig.  The version I ended up with had the "Kernel Page Size"
choice still "depends on ARCH_GENERIC_PAGE_SIZE" ... so make
menuconfig didn't let me choose the page size.

-Tony
