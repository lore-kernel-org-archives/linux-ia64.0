From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 28 Sep 2006 19:15:14 +0000
Subject: Re: EFI returning incorrect value?
Message-Id: <200609281315.15253.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <004001c6e18c$972938d0$7401a8c0@Maelstrom>
In-Reply-To: <004001c6e18c$972938d0$7401a8c0@Maelstrom>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 28 September 2006 10:33, JWM wrote:
>     My problem is that I'm trying make sure that buffers on a PCI device get
> written to with write combining enabled.

Please keep linux-ia64 copied, so other people can benefit from this
discussion.

>     I used  memmap at the EFI prompt and it shows the regions where the 
> device memory is as available (which are).
> 
>  0xCBE00000 - 0xCBEFFFFF

This MMIO region isn't described at all in the EFI memory map, so
the kernel has no idea what attributes are supported.  That's why
efi_range_is_wc() returns 0 for this range.

Your firmware people will likely respond that this MMIO region is
described via ACPI.  But Linux isn't smart enough yet to use ACPI
for this purpose.

I assume you're trying to map this region in the kernel, so a driver
can access it.  Normally you would use ioremap() or ioremap_nocache()
or maybe even pci_iomap() for this purpose.  But there's currently
no good way to ask for a write-combining mapping.

Some people have suggested an ioremap_wc(), but I guess the idea
hasn't achieved critical mass yet.

>     The ia64 ioremap doesn't seem to do the vma mappings that other 
> platforms do.

Right.  On ia64, ioremap() uses kernel identity mappings for which
there are no page tables.  If we did implement ioremap_wc(), we 
would have to do it with page tables so there would be a place to
set the WC attribute.

> After googleing the problem I've found one set of messages  
> indicating that the last person that did this had to roll their own 
> remap_area_pages and supporting routines.
>     Is that the way to go or is it just that I don't understand something 
> about the platform?

I think the high-speed interconnect folks are interested in this,
and as far as I know, they have had to roll their own stuff so far
(I haven't actually seen it).

I would think lots of people would be interested in this, so if you
came up with an ioremap_wc() implementation that is generically
useful, you might be able to make it fly.

> BS_data   0000000000000000-0000000000000FFF 0000000000000001 0000000000000008
> available 0000000000001000-000000000008AFFF 000000000000008A 0000000000000008
> BS_data   000000000008B000-000000000009FFFF 0000000000000015 0000000000000008
> RT_code   00000000000C0000-00000000000DFFFF 0000000000000020 8000000000000001
> RT_code   00000000000E0000-00000000000FFFFF 0000000000000020 8000000000000008
> available 0000000000100000-0000000077FFFFFF 0000000000077F00 0000000000000008
> RT_data   0000000078000000-000000007BFFFFFF 0000000000004000 8000000000000001
> available 000000007C000000-000000007E9ABFFF 00000000000029AC 0000000000000008
> RT_data   000000007E9AC000-000000007E9B1FFF 0000000000000006 8000000000000008
> RT_code   000000007E9B2000-000000007EDC5FFF 0000000000000414 8000000000000008
> RT_data   000000007EDC6000-000000007EF2DFFF 0000000000000168 8000000000000008
> RT_data   000000007EF2E000-000000007EF37FFF 000000000000000A 8000000000000008
> RT_data   000000007EF38000-000000007EFFFFFF 00000000000000C8 8000000000000008
> PAL_code  000000007F000000-000000007F2FFFFF 0000000000000300 8000000000000008
> available 000000007F300000-000000007FDF8FFF 0000000000000AF9 0000000000000008
> BS_data   000000007FDF9000-000000007FE07FFF 000000000000000F 0000000000000008
> RT_code   000000007FE08000-000000007FE0FFFF 0000000000000008 8000000000000008
> BS_data   000000007FE10000-000000007FE15FFF 0000000000000006 0000000000000008
> RT_code   000000007FE16000-000000007FFFFFFF 00000000000001EA 8000000000000008
> RT_data   00000000FF000000-00000000FFFFFFFF 0000000000001000 8000000000000001
> available 0000000100000000-000000047744DFFF 000000000037744E 0000000000000008
> BS_data   000000047744E000-000000047B7FDFFF 00000000000043B0 0000000000000008
> RT_data   000000047B7FE000-000000047F7FFFFF 0000000000004002 8000000000000008
> BS_data   000000047F800000-000000047F800FFF 0000000000000001 0000000000000008
> available 000000047F801000-000000047F8C5FFF 00000000000000C5 0000000000000008
> BS_data   000000047F8C6000-000000047F8C7FFF 0000000000000002 0000000000000008
> available 000000047F8C8000-000000047F8C9FFF 0000000000000002 0000000000000008
> BS_data   000000047F8CA000-000000047F9F9FFF 0000000000000130 0000000000000008
> available 000000047F9FA000-000000047F9FAFFF 0000000000000001 0000000000000008
> BS_data   000000047F9FB000-000000047F9FDFFF 0000000000000003 0000000000000008
> available 000000047F9FE000-000000047FD27FFF 000000000000032A 0000000000000008
> RT_code   000000047FD28000-000000047FD91FFF 000000000000006A 8000000000000008
> BS_code   000000047FD92000-000000047FDFDFFF 000000000000006C 0000000000000008
> available 000000047FDFE000-000000047FE2DFFF 0000000000000030 0000000000000008
> RT_code   000000047FE2E000-000000047FE7DFFF 0000000000000050 8000000000000008
> available 000000047FE7E000-000000047FFB5FFF 0000000000000138 0000000000000008
> RT_data   000000047FFB6000-000000047FFFFFFF 000000000000004A 8000000000000008
> MemPortIO 00000FFFFC000000-00000FFFFFFFFFFF 0000000000004000 8000000000000001
