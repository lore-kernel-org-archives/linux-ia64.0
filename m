From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Aug 2005 18:59:12 +0000
Subject: RE: efi_memmapwalk re-write
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0416351E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I was a little reluctant to throw away information about physical memory
>that was on the system when I wrote this code originally. That
>information could be useful for instance if we choose to implement to
>allow adding that memory back to the system without having to reboot the
>system, using hotplug memory infrastructure. Cost of retaining this
>information looked reasonable enough to me.

We already throw away information ... the existing code does it
irreversibly when it makes adjustments to the phys_addr and num_pages
fields in efi_memory_desc_t structures.  Your new code avoids doing
that, but since you coalesce sections that are usable by Linux that
are contiguous, you drop any type information that is different
between sections.

I think this is fine ... anyone that really needs to know will be
able to go look at the original efi_memory_desc_t structures.  Linux
currently doesn't need to know, so we might as well optimize these
new summary structures for use by Linux.

-Tony
