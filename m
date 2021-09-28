From: Mark Brown <broonie@kernel.org>
Date: Tue, 28 Sep 2021 11:25:19 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20210928112519.GI4199@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cf0hFtnykp6aONGL"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org>
 <20210928083751.GG9223@ediswmail.ad.cirrus.com>
 <CAK8P3a11c6eLRWKvQeSqvEicc9bMDeEEGV5fygTidoRzYf9KnQ@mail.gmail.com>
 <20210928092400.GH9223@ediswmail.ad.cirrus.com>
In-Reply-To: <20210928092400.GH9223@ediswmail.ad.cirrus.com>
To: Charles Keepax <ckeepax@opensource.cirrus.com>
Cc: Arnd Bergmann <arnd@kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>


--cf0hFtnykp6aONGL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 28, 2021 at 09:24:00AM +0000, Charles Keepax wrote:
> On Tue, Sep 28, 2021 at 10:51:36AM +0200, Arnd Bergmann wrote:

> > Other DSPs use the drivers/remoteproc/ subsystem, but that
> > is more for general-purpose DSPs that can load application
> > specific firmware rather than loading a single firmware blob
> > as you'd normally do with the request_firmware() style interface.

> > Not sure if that fits what you do. Can you point to a high-level
> > description of what this DSP does besides audio, and how
> > flexible it is? That might help find the right place for this.

> Hm... wasn't aware of that one, we should probably investigate that
> a little more at this end. From a quick look, seems a bit more like
> it is designed for much larger more general purpose probably memory
> mapped DSPs. I guess our code is a little more firmware parsing
> and loading, and a bit less generic remote proceedure call stuff.

Right, that was why I didn't suggest remoteproc - the DSPs wm_adsp
covers seem much smaller than fits comfortably with remoteproc.  You
probably could make it fit though.

--cf0hFtnykp6aONGL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmFS+54ACgkQJNaLcl1U
h9A8qQf/YB0k06nBX21Y0D9WiuzfAdegrPLdfUizVJ4VMq/8sIzxSUr3yXB0F0rR
iqS0ArRzG105rz27TluAzsoN7T1TngfvDTrQFvUBG8/xBjhNBbCxMyU7q9n8wNkC
Jjc5ylof97391uxN+1o72Unu/AOe8V6xhR4kqvQ/Sm827dp8UZIJmP0oFFw15Sgy
FCx2FaweLYfuqY4YKLdpPF3/dcvfli6O0itg7FnZHX1PLkqq5K+WKKcG5WEP+Jt2
gKccsPs2YJefc8ecZMLp6NU+T8bQraAKkpph7a2ahTNe6Ltt36E3zahy7cp7wjuZ
Nae3bwDF2mJrxNhyKnTwKBfRZvtAvg==
=SewW
-----END PGP SIGNATURE-----

--cf0hFtnykp6aONGL--
