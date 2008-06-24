From: Julia Lawall <julia@diku.dk>
Date: Tue, 24 Jun 2008 17:55:44 +0000
Subject: RE: [PATCH 3/14] arch/ia64: Eliminate NULL test and memset after
Message-Id: <Pine.LNX.4.64.0806241948120.26777@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
 <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

On Tue, 24 Jun 2008, Luck, Tony wrote:

> > As noted by Akinobu Mita in patch b1fceac2b9e04d278316b2faddf276015fc06=
e3b,
> > alloc_bootmem and related functions never return NULL and always return=
 a
> > zeroed region of memory.  Thus a NULL test or memset after calls to the=
se
> > functions is unnecessary.
>=20
> There is no commit b1fceac2b9e04d278316b2faddf276015fc06e3b in Linus' tre=
e.

I am not sure to know how to tell precisely where you are looking, but you =

can find it here:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
it;h=B1fceac2b9e04d278316b2faddf276015fc06e3b


> In addition the current alloc_bootmem() is a macro that uses __alloc_boot=
mem
> which most defintely can return NULL.

The "return NULL;" at the bottom of __alloc_bootmem is preceded by=20
panic("Out of memory");, which I assume cannot return?

> Is this against -mm or linux-next?

I pull files from the following git repository:

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

julia

