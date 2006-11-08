From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
Date: Wed, 08 Nov 2006 09:45:30 +0000
Subject: Re: [PATCH 0/1] mspec driver: compile error
Message-Id: <1162979130.7805.80.camel@sebastian.intellilink.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1162881017.13700.105.camel@sebastian.intellilink.co.jp>
	 <4550609A.7010908@sgi.com>  <20061107133512.a49b11e0.akpm@osdl.org>
	 <1162977589.7805.77.camel@sebastian.intellilink.co.jp>
	 <4551A66A.2070506@sgi.com>
In-Reply-To: <4551A66A.2070506@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jes Sorensen <jes@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bjorn_helgaas@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@gmail.com>

On Wed, 2006-11-08 at 10:42 +0100, Jes Sorensen wrote:
> Fernando Luis V=C3=A1zquez Cao wrote:
> > On Tue, 2006-11-07 at 13:35 -0800, Andrew Morton wrote:
> > The problem occurs because i386 (as expected) does not define
> > IA64_UNCACHED_ALLOCATOR. I thought that making the select expression
> > depend on IA64 as shown below might silence allmodconfig:
> >=20
> >   select IA64_UNCACHED_ALLOCATOR if IA64
> >=20
> > But my guess was wrong and the same warning appeared. It seems that "if"
> > expressions do not prevent allmodconfig from checking the symbol
> > indicated by the select the "if" is conditioning. By the way, is this
> > the expected behaviour? If so, we need to get rid of the reverse
> > dependency, modify the "depends on" line accordingly, and make
> > IA64_UNCACHED_ALLOCATOR selectable. I may be missing the whole point so
> > please correct if I am wrong.
>=20
> This patch is a bad solution as it requires people to manually select
> the uncached allocator. It should be enabled automatically by MSPEC,
> not the other way round.
>=20
> Given that MSPEC is clearly marked as depending on IA64, it seems bogus
> for i386 allmodconfig to barf over it and the problem should be fixed
> there instead IMHO.
Agreed. That is why I asked if that was allmodconfig's expected
behaviour. Andrew?

Cheers,

Fernando

