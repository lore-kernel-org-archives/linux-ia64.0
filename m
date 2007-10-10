From: Andreas Schwab <schwab@suse.de>
Date: Wed, 10 Oct 2007 09:08:31 +0000
Subject: Re: compile 2.6.23 for zx2000?
Message-Id: <jebqb7tjzk.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071010063532.GA15655@colo.lackof.org>
In-Reply-To: <20071010063532.GA15655@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Grant Grundler <grundler@parisc-linux.org> writes:

> 2) But I'm getting this error:
>   CC [M]  drivers/char/ipmi/ipmi_si_intf.o
> drivers/char/ipmi/ipmi_si_intf.c:1095: error: __param_hotmod causes a sec=
tion type conflict

This is probably the same as
<http://gcc.gnu.org/bugzilla/show_bug.cgi?id1490>.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
