From: John Kohl <jtk@rational.com>
Date: Thu, 21 Dec 2000 13:34:39 +0000
Subject: [Linux-ia64] ABI change in gcc for ia64?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mysteryboxofun"
Message-Id: <marc-linux-ia64-105590678205872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

> THIS IS A MESSAGE IN 'MIME' FORMAT.
> If you are reading this, your mail reader may not support MIME.
> Some parts of this message will be readable as plain text.

--mysteryboxofun
Content-Type: text/plain

Was there an ABI change for gcc for ia64 between 
"old":	    gcc version 2.9-ia64-000216-final
"new":	    gcc version 2.96-ia64-000717 snap 001117

We are seeing interoperation failures between code compiled with these
two versions, related to structure passing (thankfully, user-space only
for now).

I've got a test case which shows this:

caller (tv1.c)	    callee (blah.c)	result
old		    old	   		OK
old		    new			BAD
new		    old			BAD
new		    new			OK


--mysteryboxofun
Content-Type: text/plain; charset=US-ASCII; name="tv1.c"
Content-Description: ~/src/tv-test/tv1.c
Content-Transfer-Encoding: quoted-printable

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>

extern void blah(
    struct sockaddr_in *__raddr,
    u_long __program,
    u_long __version,
    struct timeval __wait_resend,
    int *__sockp
);

char carray[] =3D "Hi there.\n";

main()
{
    struct timeval tv;
    char *cp =3D carray;
    int i =3D 37;

    tv.tv_sec =3D 1;
    tv.tv_usec =3D 2;

    blah(NULL, 32, 33, tv, &i);
}


--mysteryboxofun
Content-Type: text/plain; charset=US-ASCII; name="blah.c"
Content-Description: ~/src/tv-test/blah.c
Content-Transfer-Encoding: quoted-printable

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>

extern void
blah(
    struct sockaddr_in *__raddr,
    u_long __program,
    u_long __version,
    struct timeval __wait_resend,
    int *__sockp
);

extern void
blah(
    struct sockaddr_in *__raddr,
    u_long __program,
    u_long __version,
    struct timeval tv,
    int *ip
)
{
    printf("raddr =3D %p\n", __raddr);
    printf("prog =3D %d\nvers =3D %d\n", __program, __version);
    printf("tv.tv_sec =3D %d\ntv.tv_usec =3D %d\nip =3D %p\n",
           tv.tv_sec, tv.tv_usec, ip);
    printf("int =3D %d\n", *ip);
}


--mysteryboxofun--

