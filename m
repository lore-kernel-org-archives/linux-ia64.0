From: Andreas Schwab <schwab@suse.de>
Date: Mon, 06 Jun 2005 17:04:21 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <jepsuz8lii.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>>> On Sat, 04 Jun 2005 14:18:16 +1000, Keith Owens <kaos@sgi.com> said:
>
>   Keith> On Fri, 3 Jun 2005 11:50:55 -0700,=20
>   Keith> "Luck, Tony" <tony.luck@intel.com> wrote:
>   >>> This explains why XPC has been so troublesome to load on older syst=
ems.
>   >>> Thanks Dean!
>   >>>=20
>   >>> Tony, can this still get into 2.6.12?
>   >>=20
>   >> Probably ... but the first hunk of the patch looks like a no-op,
>   >> and contravenes some style guidlines about initializing global
>   >> variables to 0.
>   >>=20
>   >> -static int shub_1_1_found __initdata;
>   >> +static int __initdata shub_1_1_found =3D 0;
>
>   Keith> There is a linker restriction that you must initialise variables=
 that
>   Keith> are to be stored in different sections, which is what __initdata=
 does.
>   Keith> without initialization shub_1_1_found ends up in .bss, with
>   Keith> initialization it ends up in .init.data.
>
> Interesting.  Strikes me as a toolchain-bug, though.  Clearly the
> __initdata declaration is in conflict with putting the data in .bss,
> yet there is no warning or error.

Can't reproduce that with gcc 3.2, or anything newer.

$ cat section.c
int __attribute__((section(".init.data"))) foo;
$ gcc -S section.c
$ cat section.s
	.file	"section.c"
	.pred.safe_across_calls p1-p5,p16-p63
	.global foo#
	.section	.init.data,"aw",@progbits
	.align 4
	.type	foo#,@object
	.size	foo#,4
foo:
	.skip	4
	.ident	"GCC: (GNU) 3.2.2"

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
