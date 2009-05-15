From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 May 2009 21:27:12 +0000
Subject: RE: [PATCH] Convert ia64 to use int-ll64.h
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3A80D567A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Somewhat to my surprise this old patch still applies (with a little
"fuzz") and builds (for tiger_defconfig) and boots.

generic_defconfig fails to build because of a type conflict on
the declaration of register_active_ranges() ... still uses u64
for args in meminit.h, but mm/init.c has "unsigned long".

Looking into this I think that all the parts that make functions
that are used as the first argument to efi_memmap_walk() match the
efi_freemem_callback_t typedef in include/linux/efi.h:

typedef int (*efi_freemem_callback_t) (unsigned long start, unsigned long end, void *arg);

may be unneeded.

I strongly suspect that this typedef should have used "u64" for the
first two arguments.  Other bits in efi.h seem to use u64 for addresses,
most notably the efi_memory_desc_t typedef.

It seems that ia64 is the only user of efi_memmap_walk ... so this
typedef can be fixed without impacting other architectures.

-Tony
