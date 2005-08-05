From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 Aug 2005 17:20:28 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04131B18@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>+		if (md->type = EFI_BOOT_SERVICES_DATA &&
>+		    md->attribute = EFI_MEMORY_UC) {

That will certainly stop this code from crashing on Tiger.

But it still doesn't really do what the comment claims it
will do.  The "attribute" field is a bitmask ... most
of the memory that was dropped because of holes or
incompatible attributes within the same granule will also
have other allowable attributes.  So final version of this
should be checking "md->attribute & EFI_MEMORY_UC" rather
than "=".

I think this will be easier to solve if Khalid takes my
example efi_gather() code into his clean up in this area.
Then we can include a "type" in kern_memdesc, and mark all
the blocks the kernel can use with one value, and all the
blocks it can't with another (so one efi_memory_desc_t may
end up creating up to three kern_memdesc structures if there
is unusable space on both the start and end of a block).
The efi_memmap_walk() will just consider the kernel usable
blocks, and efi_memmap_walk_uc() will operate on the unusable
blocks.

-Tony
