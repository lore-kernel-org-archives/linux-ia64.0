From: Andreas Schwab <schwab@suse.de>
Date: Wed, 25 Jul 2001 15:44:46 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Alex Williamson <awilliam@fc.hp.com> writes:

|> --- arch/ia64/kernel/acpi.c.orig        Wed Jul 25 09:14:04 2001
|> +++ arch/ia64/kernel/acpi.c     Wed Jul 25 09:14:22 2001
|> @@ -210,7 +210,7 @@
|>                                  * dual-8259 compatible setup.
|>                                  */
|>                                 iosapic_init(iosapic->address, iosapic->=
irq_base,
|> -                                            (madt->flags & MADT_PCAT_CO=
MPAT));
|> +                                            (1));
|>                         break;
|> =20
|>                 case ACPI20_ENTRY_PLATFORM_INT_SOURCE:

It works now with this patch.

|> This is definitely a bug in Lion firmware if this is the problem, so
|> make sure you're running the latest version.  Thanks,

I do run the latest (83B).

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

