From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Date: Fri, 22 Jul 2016 21:31:13 +0000
Subject: Re: [RFC v3 02/13] dell-smo8800: include uaccess.h
Message-Id: <201607222331.13782@pali>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart4953421.kYRFz50e9n"
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org> <1469222687-1600-3-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-3-git-send-email-mcgrof@kernel.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windri

--nextPart4953421.kYRFz50e9n
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Friday 22 July 2016 23:24:36 Luis R. Rodriguez wrote:
> sections.h is currently included and it provides dell-smo8800
> with what it needs, an upcoming change will decouple uaccess.h
> from sections.h. This driver needs to explicitly require uaccess.h
> before this change.
>=20
> v3: new to this series -- needed due to collateral of the split of
>     old linker tables from tables.h into 3 files: sections.h,
> ranges.h and tables.h
>=20
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  drivers/platform/x86/dell-smo8800.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/platform/x86/dell-smo8800.c
> b/drivers/platform/x86/dell-smo8800.c index
> 0aec4fd4c48e..37e646034ef8 100644
> --- a/drivers/platform/x86/dell-smo8800.c
> +++ b/drivers/platform/x86/dell-smo8800.c
> @@ -24,6 +24,7 @@
>  #include <linux/acpi.h>
>  #include <linux/interrupt.h>
>  #include <linux/miscdevice.h>
> +#include <linux/uaccess.h>
>=20
>  struct smo8800_device {
>  	u32 irq;                     /* acpi device irq */

This is trivial change for dell-smo8800, so you can add my Reviewed-by.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart4953421.kYRFz50e9n
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAleSkKEACgkQi/DJPQPkQ1KRqACeJoiicMAtg5mWEsbI9WpYvU9d
QYMAoJ96BAKaU28QRw5Ps8Hfd3PpDCE8
=ej6H
-----END PGP SIGNATURE-----

--nextPart4953421.kYRFz50e9n--
