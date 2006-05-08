From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 May 2006 23:28:07 +0000
Subject: RE: [PATCH 2/3] swiotlb: create __alloc_bootmem_low_nopanic and add support in SWIOTLB
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0670355D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504205929.GD14361@us.ibm.com>
In-Reply-To: <20060504205929.GD14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>, Muli Ben-Yehuda <muli@il.ibm.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, mulix@mulix.org

Jon,

Trailing white space added by part2 and part3 annoys "git" (29
total places between the two parts).

Generic builds (based on arch/ia64/defconfig or arch/ia64/configs/gensparse_defconfig)
throws out 3 warnings, one each from arch/ia64/hp/zx1/hpzx1_machvec.c,
arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c and arch/ia64/sn/kernel/machvec.c

include/asm/machvec_init.h:32: warning: initialization from incompatible pointer type

The problems is "platform_dma_init" which can be defined as
"machvec_noop()" which returns "void", not "int" at required
by your change to the ia64_mv_dma_init type.

On the plus side it does boot on ia64 Intel Tiger ... but more of
the fancier bits of this code are used by the zx1 and zx1_swiotlb
versions which I didn't get time to test today.

-Tony
