From: Jes Sorensen <jes@sgi.com>
Date: Wed, 08 Nov 2006 10:31:09 +0000
Subject: Re: [PATCH 0/1] mspec driver: compile error
Message-Id: <4551B1ED.2000405@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1162881017.13700.105.camel@sebastian.intellilink.co.jp>	<4550609A.7010908@sgi.com>	<20061107133512.a49b11e0.akpm@osdl.org>	<1162977589.7805.77.camel@sebastian.intellilink.co.jp>	<4551A66A.2070506@sgi.com>	<1162979130.7805.80.camel@sebastian.intellilink.co.jp> <20061108015618.571242fb.akpm@osdl.org>
In-Reply-To: <20061108015618.571242fb.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@osdl.org>
Cc: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando@oss.ntt.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bjorn_helgaas@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@gmail.com>

Andrew Morton wrote:
> On Wed, 08 Nov 2006 18:45:30 +0900
> Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp> wrote:
>> On Wed, 2006-11-08 at 10:42 +0100, Jes Sorensen wrote:
>>> Given that MSPEC is clearly marked as depending on IA64, it seems bogus
>>> for i386 allmodconfig to barf over it and the problem should be fixed
>>> there instead IMHO.
>> Agreed. That is why I asked if that was allmodconfig's expected
>> behaviour. Andrew?
>=20
> kconfig's `select' isn't very smart.  This is one of the reasons why one
> should avoid using it.

Hmmm, so what do we do? I really don't like the idea that one has to
manually select the uncached allocator in order for mspec to be
available.

Alternatively can move the Kconfig field for MSPEC to arch/ia64/Kconfig,
but that seems a bit dodgy too.

Cheers,
Jes
