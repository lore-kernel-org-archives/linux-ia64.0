From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 17 Jul 2003 22:52:53 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105848257900914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 17 July 2003 11:57 am, Christopher Wedgwood wrote:
> It's too early on to have the machvec stuff setup otherwise I would so
> this.  I did consider doing phyiscal calls to abstract this but it
> makes the code larger and more complex --- the current code means the
> only issue is a strncmp in the generic path and then we drop out to
> core where I assume non-SN2 people don't care much about.

I'm not sure what physical calls you're referring to.

Have you tripped over something in particular that prevents
machvec_init() from working earlier?  It needs only the system
name from acpi_get_sysname().  And acpi_get_sysname() only
requires the efi.acpi20 pointer, which is set up in efi_init().

It seems a little ugly to call machvec_init() from the middle of
efi_init(), but it looks to me like we'd have all the info we
need at that point.

> > If there are different cacheability attributes within a granule,
> > efi_memmap_walk should remove the granule from efi_memmap.  Do you
> > see that happening?
> 
> Yes.
> 
> >   I guess since PAL is mapped with a TR, we probably can live
> >   without it being in the EFI memmap, but since we use the memmap to
> >   validate accesses to /dev/mem, the wrong thing will probably
> >   happen if you try to read the PAL space.
> 
> This does happen which is why I cache the PAL bounds.  The trim code
> runs after the boot-CPUs PAL mapping.

I'm suspecting a different problem: what happens if you try to read
the PAL area through /dev/mem?  In 2.5, we check the EFI memmap to
determine whether to use cached or non-cached access.  For PAL, we
won't find it in the memmap (because we discarded the whole granule),
so we'll try to do uncached accesses to the PAL area.

Bjorn


