From: Andreas Schwab <schwab@suse.de>
Date: Tue, 23 Sep 2003 18:54:50 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434395510134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Tue, Sep 23, 2003 at 11:21:35AM -0700, Luck, Tony wrote:
>> Looking at a couple of ia64 build servers here I see zero unaligned
>> access messages in the logs.
>
> ip options can still be an odd number of bytes.  Having itanic spew bogus=
=20
> log messages is just plain wrong (yet another hardware issue pushed off o=
n=20
> software for no significant gain).

Unaligned access are a BUG.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
