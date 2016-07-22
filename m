From: James Hogan <james.hogan@imgtec.com>
Date: Fri, 22 Jul 2016 21:37:16 +0000
Subject: Re: [RFC v3 05/13] sections.h: add sections header to collect all section info
Message-Id: <18139776.6i7V2bF6CR@radagast>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart3516104.WizZC2fFe4"
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org> <1469222687-1600-6-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-6-git-send-email-mcgrof@kernel.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windri

--nextPart3516104.WizZC2fFe4
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi Luis,

On Friday 22 July 2016 14:24:39 Luis R. Rodriguez wrote:
>  arch/alpha/include/asm/sections.h     |   6 +
>  arch/arm64/include/asm/sections.h     |   6 +
>  arch/avr32/include/asm/sections.h     |   6 +
>  arch/cris/include/asm/sections.h      |   6 +
>  arch/h8300/include/asm/sections.h     |   6 +
>  arch/hexagon/include/asm/sections.h   |   6 +
>  arch/m32r/include/asm/sections.h      |   6 +
>  arch/m68k/include/asm/sections.h      |   6 +
>  arch/metag/include/asm/sections.h     |   6 +
>  arch/mips/include/asm/sections.h      |   6 +
>  arch/mn10300/include/asm/sections.h   |   6 +
>  arch/nios2/include/asm/sections.h     |   6 +
>  arch/openrisc/include/asm/sections.h  |   6 +
>  arch/score/include/asm/sections.h     |   6 +
>  arch/unicore32/include/asm/sections.h |   6 +
>  arch/xtensa/include/asm/sections.h    |   6 +

> diff --git a/arch/alpha/include/asm/sections.h b/arch/alpha/include/asm/sections.h
> new file mode 100644
> index 000000000000..e58fc679fe15
> --- /dev/null
> +++ b/arch/alpha/include/asm/sections.h
> @@ -0,0 +1,6 @@
> +#ifndef _ASM_ALPHA_SECTIONS_H
> +#define _ASM_ALPHA_SECTIONS_H
> +
> +#include <asm-generic/sections.h>
> +
> +#endif /* _ASM_ALPHA_SECTIONS_H */

Any particular reason not to use generic-y in the Kbuild files for
sections.h, ranges.h, and tables.h?

Cheers
James

--nextPart3516104.WizZC2fFe4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJXkpIUAAoJEGwLaZPeOHZ6Y9kP/AvCJcH4joUvbu18IJ7djpn3
TKhV1TsAMSKfFQyGOZaUmxpeDwk6761ClkyFvxwt+YlPTyygGZFALKMGV4f5gR5E
3hXw/93kzd3Xj7iPk1zdphRmAb+TgPQTD3NPNRMQpZGRsyNZQ6ExYy4WL78bOiRw
2n6lSKPT4AuKrAv/VPQsjoYt+JB5BDFc9r9OcTOY0nqixZzKpy6pXSW05M77kmTJ
favgf6UTMd4n46GQAD5beibV/ZlJ8CExMNPf0BAbxJ/dQzChY/Knc76/DwEkYLX/
7iC745vKIMUtCSF2dSX0gHMBx9Ij4o5sy0ev0dBdScVTbzsOm/mtMnMwfCoDLvES
8CCU5eAuwWXJkkYKruIfaJIyIKtMw/J/SOJbvnA+Mu8sWD4NbU9Koiu35KPu/64E
Fxd9b9XwoSw/C9k9HFKDmBl1HbC7r1s1poOG/2GF8S+Zm2gT+PlbkjpkvuUAwDeT
ZdbacF7tD7QvR5wwUBWv6tPv3YZuzANrKk7K/rkguSBrnZXpPEn2jjEydIATWugV
HYq2y0tZcSP8eM4d/Ms4eHCKyVOsoHwoT6fcXMPlniVEBcoz1f4YM6/u0f0W/mqx
tnZKAdSHhTUtDI+lvDHE6KZlSwwGwZ7O7v6SIgNyeCrT8dj5VrZkgW/DdxwxM2Hp
EBBEqeIdDnm0eogTRKPJ
=AQfc
-----END PGP SIGNATURE-----

--nextPart3516104.WizZC2fFe4--

