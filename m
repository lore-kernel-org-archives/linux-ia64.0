From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Wed, 01 Jun 2022 11:59:20 +0000
Subject: Re: kernel/bpf/devmap.c:1030:40: sparse: sparse: cast removes address space '__rcu' of expression
Message-Id: <20220601120013.bq5a3ynbkc3hngm5@mail>
List-Id: <linux-ia64.vger.kernel.org>
References: <202205222029.xpW3PM1y-lkp@intel.com>
 <87y1yspmmh.fsf@toke.dk>
 <20220601003834.ilvx2pik672yxuxt@mail>
 <87h7547k8c.fsf@toke.dk>
In-Reply-To: <87h7547k8c.fsf@toke.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke@redhat.com>
Cc: kernel test robot <lkp@intel.com>, kbuild-all@lists.01.org, linux-kernel@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>, "Paul E . McKenney" <paulmck@kernel.org>, linux-ia64@vger.kernel.org

On Wed, Jun 01, 2022 at 12:26:27PM +0200, Toke H=F8iland-J=F8rgensen wrote:
> Luc Van Oostenryck <luc.vanoostenryck@gmail.com> writes:
>=20
> > On Mon, May 23, 2022 at 12:30:14PM +0200, Toke H=F8iland-J=F8rgensen wr=
ote:
> >> kernel test robot <lkp@intel.com> writes:
> >>=20
> >> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/lin=
ux.git master
> >> > head:   eaea45fc0e7b6ae439526b4a41d91230c8517336
> >> > commit: 782347b6bcad07ddb574422e01e22c92e05928c8 xdp: Add proper __r=
cu annotations to redirect map entries
> >> > date:   11 months ago
> >> > config: ia64-randconfig-s031-20220522 (https://download.01.org/0day-=
ci/archive/20220522/202205222029.xpW3PM1y-lkp@intel.com/config)
> >> > compiler: ia64-linux-gcc (GCC) 11.3.0
> >>=20
> >> Hmm, so this is ia64-only? Some kind of macro breakage? Paul, any idea=
s?
> >
> > Hi,
> >
> > It's surely IA64's cmpxchg() which contains lines like:
> > 	_r_ =3D ia64_cmpxchg8_##sem((__u64 *) ptr, new, _o_);=20
>=20
> Oh, right. Hmm, well, if the cmpxchg does an internal cast that
> complicates things a bit. My immediate thought was to move the
> unrcu_pointer() inside the calls to cmpxchg(), like:
=20
> But that seems to confuse sparse because these are ptr-to-ptr
> constructs:

Yes, that can't work because it applies on the wrong level (same difference=
 as
between "int const ** ptr" and "int * const * ptr").

I've taken a quick look and the problem is really to be solved in IA64's
macros for cmpxchg() and friends. Two things need to be done:
1) avoid casts like the "(__u64 *) ptr" here above (ideally no cast would
   be needed but a "(__u64 __force *) ptr" would be pefectly acceptable in
   such macros.
2) the value returned by these macros must match the type of the pointer
   and the old/new values. For example, on x86 such macros are written as:
	({
		__typeof__ (*(ptr)) __ret =3D (arg);
		switch (sizeof(*(ptr))) {=20
		case ...
			... use ptr without dropping the address space ..

		__ret;
	)}

See, for example, arch/x86/include/asm/cmpxchg.h

-- Luc
