From: Andreas Jaeger <aj@suse.de>
Date: Fri, 04 Jun 2004 05:08:18 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <m3oenzrjul.fsf@gromit.moeb>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>>> On Tue, 01 Jun 2004 11:48:56 +0200, Andreas Jaeger <aj@suse.de> said:
>
>   Andreas> Just a clarification: AMD64 [1] has most of user space
>   Andreas> 64-bit.  Only a few applications are 32-bit - but this
>   Andreas> lib/lib64 is the best way to handle 32-bit packages (no
>   Andreas> need to change files).
>
>   >> Moving to lib32 and lib64 makes sense in that environment.
>
>   Andreas> Not lib32, just lib.
>
> That may be a reasonable solution for x86-64 but I don't think it is
> for ia64.  What's needed is multi-architecture support, not bi-arch
> support.  Let's consider some possible bi-arch setups:
>
> 			contents of:
>
> host arch:	/usr/lib	/usr/lib64
> ----------
> x86-64		x86		x86-64
> ia64		x86		ia64
> ppc64		ppc32		ppc64
>
> So far, so good.  But what if x86-64 emulation support were added to
> Intel's IA32EL?  With the bi-arch-logic, that's either not supported
> or you'd have to move the ia64-stuff _again_ from /usr/lib64 into some
> other place.  Thanks, but no thanks.  Not to mention that trying to
> move ia64 libraries from /usr/lib to /usr/lib64 is almost certainly
> worse than any ill it could possibly cure.
>
> Even if you didn't in the above scenario, it wouldn't surprise me if
> the ppc64 folks also wanted to be able to run x86 binaries.  If so,
> the bi-arch approach won't work for them either, because /usr/lib is
> already taken by ppc32.

We're speaking here about native code - and not emulations.  So, for
ia64 I only see two native codes right now: 64-bit code as it is and
code using 32-bit pointers (don't know how it's called).

And x86 on ppc64 would be an emulation - not the native code - and
would end somewhere else.

Note that what your table says about ppc64 and x86-64 above is correct
=2D and you can add s390, mips and sparc64 under the same line.  Sparc has
done this for a long time already.

For details see the FHS.  The big advantage on x86-64 [1] with lib and
lib64 is that you can use existing 32-bit x86 rpms and install them -
and they work without changes.

I don't know what Red Hat is doing with x86 and with lib64 - and you
really should ask them for clarification.

Andreas

Footnotes:=20
[1]  Note I'm more concerned with x86-64, I'm not advocating here
     anything for ia64.

=2D-=20
 Andreas Jaeger, aj@suse.de, http://www.suse.de/~aj
  SUSE Linux AG, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
   GPG fingerprint =3D 93A3 365E CE47 B889 DF7F  FED1 389A 563C C272 A126

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAwAPEOJpWPMJyoSYRAvgxAJ4kk23uRxB2ywEi9pUABc+m8BvYCwCeLmL4
8uDbud1OWG1HtJlOvTfXGaE=
=mLI5
-----END PGP SIGNATURE-----
--=-=-=--
