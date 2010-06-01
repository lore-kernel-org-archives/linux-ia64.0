From: Julia Lawall <julia@diku.dk>
Date: Tue, 01 Jun 2010 18:15:28 +0000
Subject: Re: question about arch/ia64/kernel/iosapic.c
Message-Id: <Pine.LNX.4.64.1006012014430.12546@ask.diku.dk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-511516320-1809237725-1275416128=:12546"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1809237725-1275416128=:12546
Content-Type: TEXT/PLAIN; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tue, 1 Jun 2010, Tony Luck wrote:

> On Sat, May 29, 2010 at 10:56 PM, Julia Lawall <julia@diku.dk> wrote:
> > I have the impression that ioremap should not be called with locks held.
> > Is this the case? =A0If so, what should be done in the following code (=
from
> > the function iosapic_init):
>=20
> This code is probably safe because on any sane system the I/O address
> being mapped should not fall into any of the complex cases in ioremap().
> So we'll just end up in __ioremap() ... which just does some simple math
> to get the region 6 address that provides uncacheable access to the
> physical address - which can safely be done while holding a lock.
>=20
> Did you find this because you have a code scanner that is flagging
> this as a problem?

Yes, but the question was more because I was trying to understand whether=20
the scanner should be looking for ioremap problems or not.

Thanks for the explanation.

julia
---511516320-1809237725-1275416128=:12546--
