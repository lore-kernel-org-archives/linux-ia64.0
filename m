From: Aleksa Sarai <cyphar@cyphar.com>
Date: Fri, 12 Jul 2019 15:32:27 +0000
Subject: Re: [PATCH v9 00/10] namei: openat2(2) path resolution restrictions
Message-Id: <20190712153227.owkjmx47lzrggweo@yavin>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="whm56wbfs3ehouyz"
List-Id: <linux-ia64.vger.kernel.org>
References: <20190706145737.5299-1-cyphar@cyphar.com>
 <20190712151118.GP17978@ZenIV.linux.org.uk>
In-Reply-To: <20190712151118.GP17978@ZenIV.linux.org.uk>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Jeff Layton <jlayton@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>, Shuah Khan <shuah@kernel.org>, Shuah Khan <skhan@linuxfoundation.org>, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@kernel.org>, Jann Horn <jannh@google.com>, Christian Brauner <christian@brauner.io>, David Drysdale <drysdale@google.com>, Tycho Andersen <tycho@tycho.ws>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, containers@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Chanho Min <chanho.min@lge.com>, Oleg Nesterov <ole>


--whm56wbfs3ehouyz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2019-07-12, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Jul 07, 2019 at 12:57:27AM +1000, Aleksa Sarai wrote:
> > Patch changelog:
> >   v9:
> >     * Replace resolveat(2) with openat2(2). [Linus]
> >     * Output a warning to dmesg if may_open_magiclink() is violated.
> >     * Add an openat2(O_CREAT) testcase.
>=20
> One general note for the future, BTW: for such series it's generally
> a good idea to put it into a public git tree somewhere and mention that
> in the announcement...

Sure, I'll mention it next time. For the record the tree is
  <https://github.com/cyphar/linux/tree/resolveat/master>

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--whm56wbfs3ehouyz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQSxZm6dtfE8gxLLfYqdlLljIbnQEgUCXSioAwAKCRCdlLljIbnQ
EgzkAQChn28FqDC8mwoRBSpKSsYawQ4zVuMzbt7zKNknJNg7nQD/cmJDlKpmnt40
Jbd8FP1RPFVHA8Y7yVeIE+cOpg3nbw4=
=RciL
-----END PGP SIGNATURE-----

--whm56wbfs3ehouyz--
