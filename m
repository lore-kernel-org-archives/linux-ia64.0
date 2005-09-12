From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Sep 2005 04:34:05 +0000
Subject: RE: [RFC] /proc/efi_memmap
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F045A8F02@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
In-Reply-To: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What does Kexec-people really want ?
>Excact EFI memory map ? or physical address map with some attributes ?

Not sure what their exact needs are.

>(exporiting just EFI memmap looks easy but...)
>I think EFI memory map cannot cooperate with memory hotplug and
>will be obsolete in future.
>So more generic "physical memory map" looks good.

Good point.  EFI memory map is static, so the information may
be wrong in a hot-plug memory world.

> > 1) Is /proc/efi_memmap a good name?
>just rename to memory_map and show efi's for now looks good.
>
> > +	seq_printf(m, "%4d %16.16lx %16.16lx %lx\n", md->type, 
>md->phys_addr,
> > +		efi_md_end(md), md->attribute);
>
>and please define more "generic format".
>If an interface is fixed, we can change implementation.

If this is a general memory map, rather than EFI map, then
yes, the EFI type and attributes aren't helpful.

>BTW, EFI memory map doesn't matches kernel's memory view (by 
>GRANULE etc..)
>It isn't problem for kexec-people ?

I don't see why the new kernel would have the same page and
granule size.  So it may be able to use memory that the old
kernel couldn't.

-Tony
