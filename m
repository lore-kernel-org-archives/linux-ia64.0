From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 23:14:47 +0000
Subject: patches added to release/test trees
Message-Id: <200602082314.k18NEl4H011705@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches have been added to the release/test trees:

Jes Sorensen:
      [IA64] prevent sn2 specific code to be run in generic kernels

Tony Luck:
      [IA64] Fix CONFIG_PRINTK_TIME

Zou Nan hai:
      [IA64] Fix a possible buffer overflow in efi.c
      [IA64] Fix wrong use of memparse in efi.c

The following patches have been added to the test tree:

Chen, Kenneth W:
      [IA64] map ia64_hint definition to intel compiler intrinsic
      [IA64] clean up asm/intel_intrin.h
      [IA64] add __builtin_trap definition for icc build
      [IA64] use icc defined constant

Jack Steiner:
      [IA64-SGI] - Eliminate SN pio_phys_xxx macros. Move to assembly

Keith Owens:
      [IA64] MCA: print messages in MCA handler
      [IA64] MCA: update MCA comm field for user space tasks
      [IA64] MCA: remove obsolete ifdef
