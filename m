From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 11 Jan 2010 18:35:06 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be kernel-related?
Message-Id: <201001111135.07142.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Monday 11 January 2010 11:23:30 am Luck, Tony wrote:
> >        printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
> >                "(ioc=3D%llx, lba=3D%llx)\n", (char *)context,
> >                sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
> >
> >If hp_zx1_setup returned 0, we should see the "Detected HP ZX1
> >HWP0003 AGP chipset" message next, but we don't
>=20
> Perhaps KERN_INFO is below the priority level of kernel
> messages being logged?

Oh, crap, I bet you're right.  I was assuming these were dmesg logs,
where everything would appear, but I bet they're console logs.

=C9meric, can you grab the dmesg log instead, please?

Bjorn
