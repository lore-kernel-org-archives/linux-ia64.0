From: Andreas Schwab <schwab@suse.de>
Date: Fri, 11 Jul 2003 18:49:39 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105795035010280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Nathan Straz <nstraz@sgi.com> writes:

|> On Fri, Jul 11, 2003 at 11:57:30AM +0200, Andreas Schwab wrote:
|> > Peter Chubb <peter@chubb.wattle.id.au> writes:
|> > |> I'm not finding that clone2() works -- We get a segfault in the clo=
ned
|> > |> process when it returns.
|> >=20
|> > You can't return from the function, only exit() or _exit() works.
|>=20
|> That seems really odd that you can't return from the function.

Please forget what I wrote, I've now realized that this is supposed to
work.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
