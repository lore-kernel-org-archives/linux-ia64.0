From: "Jim Hull" <jim.hull@hp.com>
Date: Wed, 12 Jan 2005 18:51:49 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <200501121851.KAA02457@lucy.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:

> But what about places that unconditionally set the WC bit 
> regardless of what the EFI memory map says?

To be blunt - those places are broken, at least from the perspective of the IPF
(ia64 if you prefer) architecture.  IPF declares that it is the platform which
gets to decide the supported attributes for each address range, and provides the
EFI memory map to inform the OS of this support.

> pci_mmap_page_range does this for 
> example if the write_combine flag is set on the vma.
> I'm looking for a way to abstract out 
> uses like that, so that shub 1.x systems don't set the bit.

I'm not really qualified to design the right linux interfaces, but to be IPF
compliant, you need to change all such places to first consult the EFI memory
map.  Whether you do this once at boot time, on every call, whether to fail an
unsupported request or remap the attribute to something the platform can support
(e.g., mapping WC to UC), is all up to you.

 -- Jim


