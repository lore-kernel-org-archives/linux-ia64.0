From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 Aug 2005 00:02:16 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F041316C1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony> So it looks like your problem is
>Tony> CONFIG_IA64_UNCACHED_ALLOCATOR=y
>
>Impossible, thats my code! It can't be broken ;-)
>
>Anyone who have tried this on an ZX1 box? Otherwise I'll try it out on
>my 2600 tomorrow and see if I can reproduce it.

It may help to know that on the tiger, efi_memmap_walk_uc decides
that this efi_memory_desc_t entry is fair game:

 type = 11 (EFI_MEMORY_MAPPED_IO)
 phys_addr = 0xfe000000
 num_pages = 0x1000
 attribute = 0x1

So despite your protests, I think that efi_memmap_walk_uc() is
very broken.  It certainly doesn't do any of the things that
it's descriptive comment says that it is going to do.  It fails
to find any of the leftover pages.

Maybe when Khalid finishes with efi_gather() you could look
at saving the addresses of any discarded memory that is UC
capable in a separate array.

-Tony
