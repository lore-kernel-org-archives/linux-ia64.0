From: Andreas Schwab <schwab@suse.de>
Date: Wed, 01 Nov 2006 15:38:05 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <jeac3bch42.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> writes:

> + make ARCH=3Dia64 oldconfig
>   HOSTCC  scripts/basic/fixdep
>   HOSTCC  scripts/basic/split-include
>   HOSTCC  scripts/basic/docproc
>   SHIPPED scripts/kconfig/zconf.tab.h
>   HOSTCC  scripts/kconfig/conf.o
>   HOSTCC  scripts/kconfig/mconf.o
> scripts/kconfig/mconf.c:91: error: static declaration of 'current_menu'=20
> follows non-static declaration
> scripts/kconfig/lkc.h:63: error: previous declaration of 'current_menu'=20
> was here
> make[1]: *** [scripts/kconfig/mconf.o] Error 1
> make: *** [oldconfig] Error 2

Your kernel sources are way out of date, this has been fixed more than two
years ago.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
