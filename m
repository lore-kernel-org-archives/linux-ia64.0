From: Andreas Schwab <schwab@suse.de>
Date: Tue, 23 Sep 2003 19:09:47 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479311309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

> On Tue, 23 Sep 2003 20:54:50 +0200
> Andreas Schwab <schwab@suse.de> wrote:
>
>> Unaligned access are a BUG.
>
> Wrong, they've been allowed in the kernel networking from day
> one and there is nothing that can be done to avoid the cases
> for which they occur.

The compiler is allowed to take advantage that there are no unaligned
accesses.  You need to use compiler extensions (like attribute packed) to
stop it from doing this.

> Stop spreading fud.

Nothing like this.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
