From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 29 Apr 2004 21:19:30 +0000
Subject: Re: [patch 1/3] efivars driver update and move
Message-Id: <20040429211930.GC15106@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="96YOpH+ONegL0A3E"
List-Id: <linux-ia64.vger.kernel.org>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEAB3@fmsmsx406.fm.intel.com> <1083268253.8416.100.camel@localhost>
In-Reply-To: <1083268253.8416.100.camel@localhost>
To: Alex Williamson <alex.williamson@hp.com>
Cc: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, akpm@osdl.org, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>


--96YOpH+ONegL0A3E
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 29, 2004 at 01:50:54PM -0600, Alex Williamson wrote:
> # stat BootOrder-8be4df61-93ca-11d2-aa0d-00e098032b8c\ /
>   File: `BootOrder-8be4df61-93ca-11d2-aa0d-00e098032b8c /'

FWIW, my Intel Tiger2-based system doesn't have the space at the end...

>         *(short_name + strlen(short_name)) =3D '-';
>         efi_guid_unparse(vendor_guid, short_name + strlen(short_name));
>         *(short_name + strlen(short_name)) =3D ' ';

even though looking at this I would have expected it to...

Can you remove that last line and see what it does?  Best as I can
tell, it isn't necessary or desired.

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--96YOpH+ONegL0A3E
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAkXFiIavu95Lw/AkRAuLhAJ9EMcgAuxZ+OMgqf5f2bMt1FHYBjACfRsJd
AUHRI8EORk+Utka3OFnP2uM=
=Q3HN
-----END PGP SIGNATURE-----

--96YOpH+ONegL0A3E--
