From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 19 Sep 2012 22:37:31 +0000
Subject: Re: [PATCH v2 2/2] PCI: Provide a default pcibios_update_irq()
Message-Id: <20120920083731.b99255eb8fdeea908d34ed2f@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Signature=_Thu__20_Sep_2012_08_37_31_+1000_w3NxfdoHc7EAjbxm"
List-Id: <linux-ia64.vger.kernel.org>
References: <1347880974-13615-1-git-send-email-thierry.reding@avionic-design.de>
 <1347880974-13615-2-git-send-email-thierry.reding@avionic-design.de>
In-Reply-To: <1347880974-13615-2-git-send-email-thierry.reding@avionic-design.de>
To: linux-arm-kernel@lists.infradead.org

--Signature=_Thu__20_Sep_2012_08_37_31_+1000_w3NxfdoHc7EAjbxm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 17 Sep 2012 13:22:54 +0200 Thierry Reding <thierry.reding@avionic-d=
esign.de> wrote:
>
> diff --git a/drivers/pci/setup-irq.c b/drivers/pci/setup-irq.c
> index 270ae7b..3d61ce3 100644
> --- a/drivers/pci/setup-irq.c
> +++ b/drivers/pci/setup-irq.c
> @@ -17,6 +17,11 @@
>  #include <linux/ioport.h>
>  #include <linux/cache.h>
> =20
> +void __weak pcibios_update_irq(struct pci_dev *dev, int irq)
> +{
> +	dev_dbg(&dev->dev, "Assigning IRQ %02d\n", irq);
> +	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
> +}
> =20
>  static void
>  pdev_fixup_irq(struct pci_dev *dev,

Didn't we have a problem with some compiler versions when the weak
definition was in the same file as the call (there is a call to this
function in drivers/pci/setup-irq.c)?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__20_Sep_2012_08_37_31_+1000_w3NxfdoHc7EAjbxm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQWkkrAAoJEECxmPOUX5FEW9wP/RZUlNoHKF/hdMIqgBXmqu9j
ziwT/7xAnOx2PyPXzlr360bi/PMcjIv3oqf4DHv1tBxYe7tzxS9j1M2Moq8UHiWW
1wOj+EXsgex73bIKtudojQojTpY9lZML9cdD5ki6zxvIEZTynAH4dSdomk2knPxw
er3HuNnawQIA4iad+FF4IFp9ojKsduCCRHEGzgC0sfLm1zT/pKgT/jQjZYjdWtKy
cTujkETaHoMG6rZdnUwmmZryGHWtPUAlWVyg9BDebJfIL32zzU66lQlpIFREyTnI
zmOrfeJ4Ypw/B0NRUvEMQbUZJtRk7L/ovddItq9NNWHgYn5pznuJOlTaPQb9owOd
i4oOZguBUyIQL92SrzMMXjxkx5RaBf8dtgGwvdvvCGv5F48Cnr3eCbQN5YQL08xQ
fek/sjc5izX0MbNjKYw4twCrOwYVpd6Hj7W8L0lhZ0NgFZIoXQi8zTmEjDtf5cHw
heVKZnH2zdtboYaiIB6utdl1/20mrq6YUd4yuQxwGpc9LveCkPxpPZ1fwTYJj6Fq
sjabH0KJVKmHTKr3LJg6xFKNh98p+Z3PlVAz4Ac6JTfCWLroBb9df9XAbHZ5kUZd
Q8RvTloTEYY6hiYKVUn7QF6iO7fUxYuY8/7s8HBhGEyJrwCrVJTpFCOgm7ySBwO5
fqCAlk6bhtq1THZ3WZZh
=VZA6
-----END PGP SIGNATURE-----

--Signature=_Thu__20_Sep_2012_08_37_31_+1000_w3NxfdoHc7EAjbxm--
