From: Alex Williamson <awilliam@fc.hp.com>
Date: Wed, 25 Jul 2001 16:00:53 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


   Andreas and Martin, thanks for finding and testing this.  Can
anyone from Intel comment on why the PCAT_COMPAT flag is not set
in the APIC on a Lion when it does have a dual-8259 style interrupt
setup?  This flag is set on a BigSur.  Is there a better, more
reliable way to flag when a platform does not support legacy
interrupts?  Thanks,

	Alex

Andreas Schwab wrote:
>=20
> Alex Williamson <awilliam@fc.hp.com> writes:
>=20
> |> --- arch/ia64/kernel/acpi.c.orig        Wed Jul 25 09:14:04 2001
> |> +++ arch/ia64/kernel/acpi.c     Wed Jul 25 09:14:22 2001
> |> @@ -210,7 +210,7 @@
> |>                                  * dual-8259 compatible setup.
> |>                                  */
> |>                                 iosapic_init(iosapic->address, iosapic=
->irq_base,
> |> -                                            (madt->flags & MADT_PCAT_=
COMPAT));
> |> +                                            (1));
> |>                         break;
> |>
> |>                 case ACPI20_ENTRY_PLATFORM_INT_SOURCE:
>=20
> It works now with this patch.
>=20
> |> This is definitely a bug in Lion firmware if this is the problem, so
> |> make sure you're running the latest version.  Thanks,
>=20
> I do run the latest (83B).
>=20
> Andreas.
>=20
> --
> Andreas Schwab                                  "And now for something
> SuSE Labs                                        completely different."
> Andreas.Schwab@suse.de
> SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--
Alex Williamson                                  Linux Development Lab
awilliam@fc.hp.com                                     Hewlett Packard
970-898-9173                                          Fort Collins, CO

