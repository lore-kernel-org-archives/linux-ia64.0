From: Andreas Schwab <schwab@suse.de>
Date: Mon, 22 Aug 2005 22:16:53 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <jell2tzkfe.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Gerald Pfeifer <gp@suse.de> writes:

>   `-mmemcpy'
>   `-mno-memcpy'
>       The `-mmemcpy' switch makes all block moves call the appropriate
>       string function (`memcpy' or `bcopy') instead of possibly
>       generating inline code.

All -m* options are target dependent, and ia64 does not have such an
option.  In fact, this option only exists on MIPS targets.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
