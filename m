From: n0ano@indstorage.com
Date: Wed, 24 Oct 2001 19:50:05 +0000
Subject: Re: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Gururaj-

Sigh.  Intel's example has nothing to do with unions not working,
unions work fine.  All the example was pointing out is that any
code that assumes sizes of data items is risky.  This slide is
a little unclear - using a union will not corrupt data, it might
cause your code to use unexpected data.

A better example would be:

	struct s1 {
		int i1;
		int i2;
		int i3;
	};

	struct s2 {
		long l1;
		long l2;
		long l3;
	};

	union un {
		struct s1;
		struct s2;
	} u;

	u.s1.i2 =3D 1;
	u.s2.l1 =3D 0;
	printf("i2 =3D %d\n", u.s1.i2);

will print out `i2 =3D 1' on an IA32 machine and `i2 =3D 0' on an
IA64 machine.  Both answers are correct, it's just that on an IA32
machine int's and long's are the same size and on an IA64 machine
they are different.

Anytime you use a union to look at the same memory contents with
different layouts you are doing something that is risky and should
be avoided if at all possible.  This is true for any architecture.

PS: Interestingly enought, I believe Intel's slide is actually
wrong.  If `ULONG' is an `unsigned long' and `PVOID' is a `void *'
then all of the data items have the same size and the two structures
can be used interchangably on either IA32 or IA64.  It's a
dangerous technique but it would work in this case.

On Wed, Oct 24, 2001 at 11:52:40AM -0700, Gururaj Ananthateerta wrote:
> http://developer.intel.com/design/itanium/linuxDDPorting/sld025.htm
>=20
> The above link provides an example.
>=20
>=20
>=20
> Andreas Schwab wrote:
>=20
> > Gururaj Ananthateerta <gururaj@cup.hp.com> writes:
> >
> > |> Anyone experienced (memory corruption ) problems with unions on ia-6=
4.
> > |> I have found couple of documents which discourages the use of unions=
 on
> > |> ia-64 in particular.
> >
> > Please expand.  Unions are an integral part of C, without them you could
> > not call it C.
> >
> > Andreas.
> >
> > --
> > Andreas Schwab                                  "And now for something
> > Andreas.Schwab@suse.de                          completely different."
> > SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> > Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

