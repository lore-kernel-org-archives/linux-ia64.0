From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Sep 2005 19:33:24 +0000
Subject: RE: efi_memmapwalk re-write (please test)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0453803A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
In-Reply-To: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>So its really close on sn2.  I'm not sure exactly what's going wrong,
>but with the new efi_memmap_walk stuff something is getting clobbered, I think.

Martin,

Thanks for taking a look at this.

To debug this ... try taking the original code, and add a printk()
to efi_memmap_walk() to show the start/end addresses that it passes
off [you need two printk() as the last piece of memory gets its own
callsite].  Compare this with the addresses that the debug code
prints at the end of efi_memmap_init().  The lists should be identical.

-Tony
