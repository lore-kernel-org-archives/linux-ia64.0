From: Arjan van de Ven <arjanv@redhat.com>
Date: Sun, 18 May 2003 09:29:02 +0000
Subject: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-0c7yDvAUspW93r7FLMOK"
Message-Id: <marc-linux-ia64-105590723705930@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-0c7yDvAUspW93r7FLMOK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2003-05-18 at 06:09, Jes Sorensen wrote:
> Hi Linus,
>=20
> This is patch which provides support for 64 bit address allocations from
> pci_alloc_consistent(), based on the address mask set through
> pci_set_consistent_dma_mask(). This is necessary on some platforms which
> are unable to provide physical memory in the lower 4GB block and do not
> provide IOMMU support for cards operating in certain bus modes, such as
> PCI-X on the SGI SN2.

I rather see a slightly different interface for this all together.
Right now the template for doing this is that the driver needs to check
the return value of the "set to 64 bit" operation and itself fall back
to 32 bit etc. What the driver really wants to achieve is to announce
device capabilities. The current interface is sort of also used to
retrieve the capability as well, which is a whole different thing.

An interface like

#define PCI_DMA_64BIT 0xffffffffffffffffULL
#define PCI_DMA_32BIT 0xffffffffULL

void pci_set_dma_capabilities(device,=20
               u64 streaming_mask, u64 persistent_mask);
u64 pci_get_effective_streaming_mask(device);
u64 pci_get_effective_persistent_mask(device);

if for some reason the architecture PCI code needs or wants to reduce
the DMA mask (for example on non-PAE36 x86 kernels) it now doesn't need
to return failure for the 64 bit mask (and maybe even the 32 bit one)
but it can just do it. All places in drivers that actually care about
the resulting, effective DMA mask now have an interface to get this.=20
Why this interface? I think it fits closer to what drivers use it for;
uncomplicated announcing of the hardware's capabilities and independent
checking of the effective mask, for example for the decision about what
DMA descriptor model to use in some communications ringbuffer.

Greetings,
   Arjan van de Ven

--=-0c7yDvAUspW93r7FLMOK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA+x1JdxULwo51rQBIRAq3NAKCmG/bNGJ9a/bRHe5J1cxGVl+g+OwCfSKRa
oAI1Nf+7x7nWRwcgp3H7OhY=
=OY5f
-----END PGP SIGNATURE-----

--=-0c7yDvAUspW93r7FLMOK--

