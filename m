From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 06 May 2004 12:46:49 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040506124649.GA13482@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
To: Sourav Sen <souravs@india.hp.com>
Cc: matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
> The following simple patch creates a read-only file
> "memmap" under <mount point>/firmware/efi/ in sysfs
> and exposes the efi memory map thru it.

I'm not generally opposed, but have a couple questions.

1) Why does userspace / humans need to know this?  For debugging firmware?

2) Can the memory map output ever be larger than PAGE_SIZE (lower
limit is 4KB on x86)?  If not, what guarantees that?  If so, you need
your own read mechanism rather than the generic sysfs one.

The one-value-per-file rule has an exception for an array of values of
the same type per Documentation/filesystems/sysfs.txt, which this
looks to adhere to.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAmjO4Iavu95Lw/AkRAoxxAJ99zD9QmdRbNgIsPvXhDlkv1Pd1wACgmy+J
xAUZX4bT/l6iKB2IASkd6To=
=hG3g
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
