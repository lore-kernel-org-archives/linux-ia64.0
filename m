From: Andreas Dilger <adilger@clusterfs.com>
Date: Wed, 15 Dec 2004 21:03:46 +0000
Subject: Re: [PATCH] add legacy I/O and memory access routines to /proc/bus/pci API
Message-Id: <20041215210346.GK9923@schnapps.adilger.int>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="x1F0m3RQhDZyj8sd"
List-Id: <linux-ia64.vger.kernel.org>
References: <200412140941.56116.jbarnes@engr.sgi.com> <200412150927.51733.jbarnes@engr.sgi.com>
In-Reply-To: <200412150927.51733.jbarnes@engr.sgi.com>
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cu, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, bjorn.helgaas@hp.com


--x1F0m3RQhDZyj8sd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Dec 15, 2004  09:27 -0800, Jesse Barnes wrote:
> +write
> +  Legacy I/O port space reads and writes must also be to a file
> +  position >64k--the kernel will route them to the target device.

Shouldn't that be < 64k based on the description of lseek?

> +lseek
> +  Can be used to set the current file position.  Note that the file
> +  size is limited to 64k as that's how big legacy I/O space is.

> +ioctl
> +  Note that not all architectures support the *_MMAP_* or *_RW_* ioctl
> +  commands.  If they're not supported, ioctl will return -EINVAL.

Shouldn't they return -ENOTTY?  That indicates to the caller that the
ioctl isn't handled, vs -EINVAL which indicates bad value being passed
(e.g. bad write size).

Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://members.shaw.ca/adilger/             http://members.shaw.ca/golinux/


--x1F0m3RQhDZyj8sd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBwKaypIg59Q01vtYRAoh8AKDmi9a8/dvTmXLivSzSXUPFDWZrHwCeOmpR
dnDEkYV/qdZa16A2p71gpqs=
=y7d8
-----END PGP SIGNATURE-----

--x1F0m3RQhDZyj8sd--
