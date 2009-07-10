From: "'Ali Polatel'" <polatel@gmail.com>
Date: Fri, 10 Jul 2009 21:54:38 +0000
Subject: Re: sydbox and ia64
Message-Id: <20090710215438.GA30695@harikalardiyari>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
List-Id: <linux-ia64.vger.kernel.org>
References: <20090710160603.GE749@harikalardiyari>
In-Reply-To: <20090710160603.GE749@harikalardiyari>
To: linux-ia64@vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=iso-8859-9
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Yu, Fenghua yazm=FD=FE:
> >These functions more or less work fine, the two functions i need help
> >with are:
> >trace_set_string: Set a string argument of the system call.
> >  This function is used to change some path arguments to /dev/null so
> >  that the application running under sydbox thinks everything is fine
> >  but in reality it writes to /dev/null, not the actual file. We call
> >  this write predicted paths.
> >trace_fake_stat: Fake stat buffer of stat() call.
> >  This function is used to implement the so-called magic commands.
> >  When run under sydbox the stat()'ing the path /dev/sydbox returns the=
=20
> >  faked stat buffer, not the actual one (which is failure because it
> >  doesn't exist.)
> >
> >Both of these functions use ptrace(PTRACE_POKEDATA, ...) to poke data to
> >child's memory area and both of these functions don't work as expected.
> >I suspect additional hackery is involved to make them work. I'd
> >appreciate if anyone with knowledge about ptrace() and itanium
> >processors be kind enough to look at this file and tell me what's wrong
> >:-].
> >Thanks in advance.
> >
> >
> >=B9: These functions reside in trace.c which you can see here:
> >   http://github.com/alip/sydbox/blob/ia64/src/trace.c
> >   For those who want to clone the repository, the git url is:
> >   git://github.com/alip/sydbox.git
> >
> What is the error of using ptrace(PTRACE_POKEDDATA, ...)? Does it return =
-1 and errno? Or peeked data is not correct?
>=20
ptrace(PTRACE_POKEDATA, ...) returns success but the peeked data isn't
correct. I was a bit wrong in my first email, trace_set_string does work
correctly. As an example:

#include <fcntl.h>
#include <stdio.h>

int main(void)
{
    char *dsw =3D "/dev/sydbox/write//";
    open(dsw, O_RDWR);
    fprintf(stderr, "%s\n", dsw);
    return 0;
}

This prints /dev/null when run under sydbox because trace_set_string is
called to replace the path with /dev/null. (If you're interested, this
is a magic command to add the path "/" to the list of write enabled
path prefixes.)

So far so good, trying a similar example now with stat:

#include <stdio.h>
#include <sys/stat.h>

int main(void)
{
    int ret;
    struct stat buf;

    ret =3D stat("/dev/sydbox", &buf);
    if (0 > ret)
        return 1;
    fprintf(stderr, "ret: %d\n", ret);
    fprintf(stderr, "isdir: %s\n", S_ISDIR(buf.st_mode) ? "yes" : "no");
    fprintf(stderr, "uid: %d, gid: %d\n", buf.st_uid, buf.st_gid);
    return 0;
}

Running this under sydbox on x86_64 gives:
ret: 0
isdir: yes
uid: 0, gid: 0
But on ia64 i get totally random results:
ret: 38
isdir: no
uid: 1610612736, gid: 1210

There's something unportable in trace_fake_stat() that i can't figure
out. Any help or pointers appreciated.
Thanks in advance.

> Thanks.
>=20
> -Fenghua
>=20

--=20
Regards,
Ali Polatel

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)

iEYEABECAAYFAkpXuJ4ACgkQQU4yORhF8iCoggCcD0DNPdMB9rxs+ACvJaYhZPJO
gSkAn1Y0OSZCooI73fNUwId5Z7IklFC1
=rxRR
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
