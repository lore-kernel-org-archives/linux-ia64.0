From: Daniel Thompson <daniel.thompson@linaro.org>
Date: Mon, 28 Mar 2022 13:47:05 +0000
Subject: Re: [PATCH 00/22] Replace comments with C99 initializers
Message-Id: <20220328134705.lnxwwznhw622r2pr@maple.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
In-Reply-To: <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?utf-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sun, Mar 27, 2022 at 02:46:00PM +0200, Benjamin St=FCrz wrote:
> This patch series replaces comments with C99's designated initializers
> in a few places. It also adds some enum initializers. This is my first
> time contributing to the Linux kernel, therefore I'm probably doing a
> lot of things the wrong way. I'm sorry for that.

Welcome!


> I've gotten a few emails so far stating that this patch series is
> unnecessary. Yes, in fact this patch series is not necessary by itself,
> but it could help me understand how the whole process works and maybe I
> could help somewhere, where help is actually needed.

Have you been told the series is unnecessary or too big?

Although all patches represent a variant of the same mechanical
transformation but they are mostly unrelated to each other and, if
accepted, they will be applied by many different people.

Taken as a whole presenting this to maintainers as a 22 patch set is too
big. I'd recommend starting with a smaller patch or patch series where
all the patches get picked up by the same maintainer.


> This patch itself is a no-op.

PATCH 0/XX is for the covering letter. You should generate a template for
it using the --cover-letter option of git format-patch. That way patch 0
will contain the diffstat for the whole series (which is often useful
to help understand what the series is for) and there is no need to
make no-op changes.


Daniel.

>=20
> Signed-off-by: Benjamin St=FCrz <benni@stuerz.xyz>
> ---
>  .gitignore | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/.gitignore b/.gitignore
> index 7afd412dadd2..706f667261eb 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -20,7 +20,7 @@
>  *.dtb
>  *.dtbo
>  *.dtb.S
> -*.dwo
> +*.dwo
>  *.elf
>  *.gcno
>  *.gz
> --=20
> 2.35.1
