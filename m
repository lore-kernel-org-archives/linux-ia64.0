From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Jun 2007 06:34:43 +0000
Subject: Re: [PATCH 3/3] Make jprobes a little safer for users
Message-Id: <1182839683.6673.22.camel@concordia.ozlabs.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-7sXp+LJveeT4iXK22RD/"
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
	 <7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
	 <863e9df20706252319j239eaf44wee7a46ad742c9585@mail.gmail.com>
In-Reply-To: <863e9df20706252319j239eaf44wee7a46ad742c9585@mail.gmail.com>
To: Abhishek Sagar <sagar.abhishek@gmail.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com


--=-7sXp+LJveeT4iXK22RD/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-26 at 11:49 +0530, Abhishek Sagar wrote:
> On 6/26/07, Michael Ellerman <michael@ellerman.id.au> wrote:
>=20
> > We can then use that in register_jprobe() to check that the entry point
> > we're passed is actually in the kernel text, rather than just some rand=
om
> > value.
>=20
> A similar cleanup is possible even for return probes then. I wonder if
> there are any kprobe related scenarios where the executable code may
> be located outside the core kernel text region (e.g, ITCM?). In that
> case would it also be wrong to assume that the jprobe handler may be
> situated outside the kernel core text / module  region? Would it then
> make sense to move this check from register_jprobe() to the arch
> dependent code?

It did occur to me that someone might be doing something crazy like
branching to code that's not in the kernel/module text - but I was
hoping that wouldn't be the case. I'm not sure what ITCM is?


> >  int __kprobes register_jprobe(struct jprobe *jp)
> >  {
> > +       unsigned long addr =3D arch_deref_entry_point(jp->entry);
> > +
> > +       if (!kernel_text_address(addr))
> > +               return -EINVAL;
>=20
> Seems like you're checking for the jprobe handler to be within
> kernel/module range. Why not narrow this down to just module range
> (!module_text_address(addr), say)? Core kernel functions would not be
> ending with a 'jprobe_return()' anyway.

There's jprobe code in net/ipv4/tcp_probe.c and net/dccp/probe.c that
can be builtin or modular, so I think kernel_text_address() is right.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-7sXp+LJveeT4iXK22RD/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGgLODdSjSd0sB4dIRAj+KAJ9J5aHP0M3+RIXR6GhgJ1LLVLWyKACgn3nQ
Kfwu91i8BrTrR082hxzola0=
=rkvM
-----END PGP SIGNATURE-----

--=-7sXp+LJveeT4iXK22RD/--

