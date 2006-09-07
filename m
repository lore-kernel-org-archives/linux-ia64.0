From: Andreas Schwab <schwab@suse.de>
Date: Thu, 07 Sep 2006 16:44:30 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <jek64fr5ht.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> But looking before that instruction r37 is a copy of r39 (mov r37=3Dr39).
> r39 was calculated by "addl r39=3D0,r1" i.e. r1+0, also known as "r1".

0 is modified by the result of the GOT relocation for __gp.

> and put it in head.S to bypass this "cleverness" by gcc and

__gp has no special meaning for gcc.  It's just another global variable.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
