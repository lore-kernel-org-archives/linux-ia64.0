From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 06 Feb 2004 08:37:41 +0000
Subject: Re: gcc problems
Message-Id: <20040206083741.GA2946@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
To: linux-ia64@vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 06, 2004 at 12:00:58AM -0800, Andrew Morton wrote:
> gcc-3.3.2/ia64 is falling over here with my current tree so I'm trying to
> build gcc-3.4 from current gcc CVS.

That probably shouldn't be happening... It's what we use all the time.
I assume gcc is segfaulting?
=20
> Is there some trick to this?  And what is the preferred gcc version for
> ia64 kernels?

Well I don't know exactly about that CVS gcc problem, but something
that may be useful if you use Debian is that there is a little known
'gcc-snapshot' package that is usually quite up to date and saves you
having to build yourself.  See the README.Debian for a sample wrapper.

-i
--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAI1JVWDlSU/gp6ecRAhbvAJsFHriZhIgd6fqwZ2so1nbg8StyCwCdF0cN
a5Gk78rU/zjwO3iPPW4r7BA=
=Oq9M
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--
