From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 19 Jan 2005 19:33:07 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <1106163187.15061.21.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-01-19 at 10:38 -0800, Luck, Tony wrote:
> >> Does the EFI memory map help here?  Is I/O memory included
> >> in the efi memory map?  What about the hot-plug case ... the
> >> EFI memory map isn't updated for new i/o memory that appears
> >> when you plug in a new card?
> >
> >I think it's supposed to appear as memory mapped I/O or memory 
> >mapped I/O port space in the EFI memory map.  Shouldn't the map
> >be updated in the case of hotplug?
> 
> I'm not an EFI expert ... but it looks like the i/f to get the
> memory map is only part of the boot time services, not the runtime
> services.  If that's right, then I don't think there's a way for
> it to be updated.

That's correct.  The EFI memory map is only a boot-time interface.
You have to learn about hot-plug stuff via ACPI.

