From: Andreas Schwab <schwab@suse.de>
Date: Tue, 06 Feb 2001 12:56:13 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590693005118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"H . J . Lu" <hjl@valinux.com> writes:

|> On Wed, Jan 24, 2001 at 01:37:24PM -0800, Jim Wilson wrote:
|> > >I guess it is a long standing issue in the Cygnus toolchain. The
|> > >problem is this change:
|> > >Bascallly, it sets local_prefix =3D prefix, which means
|> > >$local_prefix/include =3D $prefix/include
|> >=20
|> > >Now, gcc will search /usr/include before others. It is not very good
|> > >for Linux.
|> >=20
|> > Yes, this is a problem.
|> >=20
|> > I've reverted the Cygnus local change in my source tree, and have star=
ted
|> > working to get the same change into the main Cygnus source tree.  This=
 will
|> > require changing some local build processes, so it may take a little t=
ime.
|> >=20
|> > There is no problem with cross compilers as you suggested, because cro=
ss
|> > compilers don't use /usr/local/include.  I believe the original proble=
m was
|> > that we shipped compilers to some customers that had random files in
|> > /usr/local, the customers reported problems, and we had a lot of troub=
le
|> > debugging the problem.  We fixed it by deciding not to use /usr/local/=
include
|> > by default anymore.  This was 8 years ago, so Linux usage was not a co=
ncern.
|> > Now that we are part of Red Hat, it is a serious concern.
|> >=20
|> > The resulting patch is 100K because configure had to be rebuilt.  I pu=
t it
|> > in the usual place, ftp.cygnus.com:/pub/ia64-linux/snap-001117/patch.0=
55.
|> >=20
|>=20
|> I don't think it works with the gnupro rpm from RedHat. I had to
|> add the patch enclosed here. I think the problem is includedir in gcc
|> is overriden from the toplevel Makefile.

This is a very old bug that I have already reported twice (see
http://gcc.gnu.org/ml/gcc-patches/1999-07/msg00488.html and
http://gcc.gnu.org/ml/gcc-patches/1999-05/msg00477.html).

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

