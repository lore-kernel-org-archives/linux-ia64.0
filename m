From: Mark Brown <broonie@kernel.org>
Date: Tue, 28 Sep 2021 11:58:56 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20210928115856.GK4199@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mPOSj6iWmtyhwOMz"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org>
In-Reply-To: <20210928075216.4193128-1-arnd@kernel.org>
To: Arnd Bergmann <arnd@kernel.org>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Liam Girdwood <lgirdwood@gmail.com>, Charles Keepax <ckeepax@opensource.cirrus.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org


--mPOSj6iWmtyhwOMz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 28, 2021 at 09:50:26AM +0200, Arnd Bergmann wrote:

> Compile-testing drivers that require access to a firmware layer
> fails when that firmware symbol is unavailable. This happened
> twice this week:

...

> We should probably do the same thing for other subsystems as well,
> but fix this one first as this is a dependency for other patches
> getting merged.

Reviwed-by: Mark Brown <broonie@kernel.org>

Regardless of what we do with the Cirrus DSP this just seems like a good
idea - surprises due to this not being generally available keep coming
up, IIRC with the i.MX firmware in the past for example.

> Not sure how we'd want to merge this patch, if two other things
> need it. I'd prefer to merge it along with the QCOM_SCM change
> through the soc tree, but that leaves the cirrus firmware broken
> unless we also merge it the same way (rather than through ASoC
> as it is now).

We could also merge a tag into both places.

> Alternatively, we can try to find a different home for the Cirrus
> firmware to decouple the two problems. I'd argue that it's actually
> misplaced here, as drivers/firmware is meant for kernel code that
> interfaces with system firmware, not for device drivers to load
> their own firmware blobs from user space.

Trying to enforce distinctions here feels like it's liable to lead to
trouble at some point...

--mPOSj6iWmtyhwOMz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmFTA38ACgkQJNaLcl1U
h9DErAf7BZ8NtQuQy3+q/sK46z5J4UG49n7Ro2RwX1QsUE9ptW/j3QNct+oR2NtG
686Ywi+SLiwvjt9AOMEEwLrMr8VpbfKHtzNF3IFoqlZcIltP8SikGt7hl1drc7Ht
5s1rVT2od8Z49zvKru0SLEmIczlvfThmmEe7hH0klv/7eiYsIse//b/7UbCk03lc
BSU0mVLjlyBSIN6k6yU5V/JUnUwwNaWlTMficv4UITM2Ba6zjFS2WE2NlUhLcCv/
yHwgZhRm3quHTTRoJDelHsIqz65f4GxgXsMm4Olo/IZswnUh9Uk/LNMKRcHvlPg2
lP63ixob10ht4mAPh8V0shZi3aeH4g==
=nQ30
-----END PGP SIGNATURE-----

--mPOSj6iWmtyhwOMz--
