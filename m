From: Andreas Schwab <schwab@suse.de>
Date: Thu, 07 Sep 2006 09:08:34 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <jefyf4rqlp.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Takao Indoh <indou.takao@jp.fujitsu.com> writes:

> The disassemble code:
> a000000100047080:       0b 38 01 02 00 24       [MMI]       addl r39=3D0,=
r1;;
> a000000100047086:       50 02 9c 00 42 00                   mov r37=3Dr39
> a00000010004708c:       00 00 04 00                         nop.i 0x0;;
> a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr37;;
> a000000100047096:       c0 02 80 00 42 00                   mov r44=3Dr32
> a00000010004709c:       00 00 04 00                         nop.i 0x0
> a0000001000470a0:       17 00 02 51 02 14       [BBB]       br.call.sptk.=
many b0=A0000001000db4a0 <crash_kexec>
>
> This disassembled code does not change content of r1.

It does:

a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr37;;

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
