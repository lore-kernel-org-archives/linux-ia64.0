From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 11 Oct 2001 04:39:57 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.11)
Message-Id: <marc-linux-ia64-105590698805332@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

On Wed, 10 Oct 2001 19:47:41 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>An updated ia64 patch for 2.4.11 is now available at
>ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:
>
>	linux-2.4.11-ia64-011010.diff*

kdb v1.9-2.4.11-ia64-011010 is available in
ftp://oss.sgi.com/projects/kdb/download/ia64, no major changes from
2.4.10-ia64-010924.

bfd.h and ansidecl.h are now included as part of the kdb patch instead
of assuming that they exist in /usr/include, the kdb Makefiles have
been changed accordingly.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE7xSKci4UHNye0ZOoRAp7hAKCuyj149d93N4rQL61UMAy2IVPKUwCg+FTM
z9Owfl+Q0yxyp11KovUUYhc=9Xx/
-----END PGP SIGNATURE-----


