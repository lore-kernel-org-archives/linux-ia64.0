From: Andreas Schwab <schwab@suse.de>
Date: Thu, 22 Jan 2004 09:42:31 +0000
Subject: Re: [2.6.1] eepro100 Taints kernel warning:
Message-Id: <jezncgtj3s.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040122024556.GA399@cse.unsw.EDU.AU>
In-Reply-To: <20040122024556.GA399@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Darren Williams <dsw@gelato.unsw.edu.au> writes:

> When loading the eepro100 driver module I get the=20
> following warning:
>
> eepro100: no version for "per_cpu__local_per_cpu_offset" found: kernel ta=
inted.

This is a bug in genksyms, see
<http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=106570613115664&w=3D2>.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
