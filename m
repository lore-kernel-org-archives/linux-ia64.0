From: Aleksa Sarai <cyphar@cyphar.com>
Date: Thu, 05 Sep 2019 13:40:17 +0000
Subject: Re: [PATCH v12 01/12] lib: introduce copy_struct_{to,from}_user helpers
Message-Id: <20190905134017.rstiqa6v6roslzlu@yavin.dot.cyphar.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="lfmn5rszd42a2efo"
List-Id: <linux-ia64.vger.kernel.org>
References: <20190904201933.10736-1-cyphar@cyphar.com>
 <20190904201933.10736-2-cyphar@cyphar.com>
 <20190905110544.d6c5t7rx25kvywmi@wittgenstein>
In-Reply-To: <20190905110544.d6c5t7rx25kvywmi@wittgenstein>
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>, Shuah Khan <shuah@kernel.org>, Shuah Khan <skhan@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Christian Brauner <christian@brauner.io>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Tycho Andersen <tycho@tycho.ws>, David Drysdale <drysdale@google.com>, Chanho Min <chanho.min@lge.com>, Oleg


--lfmn5rszd42a2efo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2019-09-05, Christian Brauner <christian.brauner@ubuntu.com> wrote:
> On Thu, Sep 05, 2019 at 06:19:22AM +1000, Aleksa Sarai wrote:
> > A common pattern for syscall extensions is increasing the size of a
> > struct passed from userspace, such that the zero-value of the new fields
> > result in the old kernel behaviour (allowing for a mix of userspace and
> > kernel vintages to operate on one another in most cases). This is done
> > in both directions -- hence two helpers -- though it's more common to
> > have to copy user space structs into kernel space.
> >=20
> > Previously there was no common lib/ function that implemented
> > the necessary extension-checking semantics (and different syscalls
> > implemented them slightly differently or incompletely[1]). A future
> > patch replaces all of the common uses of this pattern to use the new
> > copy_struct_{to,from}_user() helpers.
> >=20
> > [1]: For instance {sched_setattr,perf_event_open,clone3}(2) all do do
> >      similar checks to copy_struct_from_user() while rt_sigprocmask(2)
> >      always rejects differently-sized struct arguments.
> >=20
> > Suggested-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> > Signed-off-by: Aleksa Sarai <cyphar@cyphar.com>

[...]

> > +	if (unlikely(!access_ok(src, usize)))
> > +		return -EFAULT;
> > +
> > +	/* Deal with trailing bytes. */
> > +	if (usize < ksize)
> > +		memset(dst + size, 0, rest);
[...]
> That's a change in behavior for clone3() and sched at least, no? Unless
> - which I guess you might have done - you have moved the "error out when
> the struct is too small" part before the call to copy_struct_from_user()
> for them.

Yes, I've put the minimum size check to the callers in all of the
cases (in the case of clone3() I've #define'd a CLONE_ARGS_SIZE_VER0 to
match the others -- see patch 2 of the series).

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--lfmn5rszd42a2efo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQSxZm6dtfE8gxLLfYqdlLljIbnQEgUCXXEQPQAKCRCdlLljIbnQ
EmI0AQDWLDq3CfEAPKhr2gyUgsbcgKNMnsXSA4qFj1Jjd61fzQEAqPhisgSoisGO
mIYO56C9d94ktWhTGVP9Bs10TG3V/Ac=
=1PLZ
-----END PGP SIGNATURE-----

--lfmn5rszd42a2efo--
