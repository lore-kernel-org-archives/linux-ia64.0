From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Aug 2005 22:45:09 +0000
Subject: Re: efi_memmapwalk re-write
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>one on x86. This patch is relative to 2.6.13-rc3 and applies on top of 
>the EFI memory map walk rewrite patch at 
><http://free.linux.hp.com/~khalid/ia64/efi_memmapwalk_2.6.13rc3.patch>
>(Tony, this EFI memory map walk patch is same as the one I sent you this
>morning).

Khalid,

Thanks for working on this.  I'm sorry it has taken this long to look
at it.

I think some areas can still benefit from more simplification.  The only
place I see you split a kern_memdesc_t is in efi_trim_memory() in order
to limit memory according to either of mem_limit or max_addr.  Wouldn't
it be simpler to just adjust num_pages element of the element instead
of splitting?

If you do that ... then you don't need to have a linked list of kern_memdesc
structures, you can treat them just like an array, nor do you need
MEM_DESC_SAFETY_MARGIN

Likewise the granule alignment functions.  The original trim_top() and
trim_bottom() are insanely complex ... and perhaps you were led astray
trying to duplicate their behaivour?  I believe that you should end up
with the desired behaivour if you just do any coalescing of memory blocks
that are WB and have one of the allowable types, then round the base
addresses up to granule boundaries and the tops down.  All that scanning
around looking for holes or non-WB sections of memory looks pointless to
me ... perhaps I'm missing some incredible subtlety in the original?

By only copying from "is_available()" types into kern_memdesc_t structures
you can avoid calling is_available() in your new efi_memmap_walk(), and
indeed drop the "type" field from the structure.

find_memmap_space() should be in efi.c ... just pass a pointer to space
for it to fill in the address of the block it allocated and have it
return the size so that reserve_memory() can fill these into an entry
in rsvd_region[].  It shouldn't use is_available_memory() to decide
which blocks are candidates for the allocation.  This could result in
choosing memory that is still in use by EFI, command line arguments, or
even overwriting the kernel.  EFI_CONVENTIONAL_MEMORY is definitely
safe for this, perhaps EFI_LOADER_CODE too?

It is not OK to call "machine_restart()" if you couldn't allocate space.
This would put the machine into a loop ... rebooting and failing, with
no oportunity to read the error message.  Just use panic().

-Tony

