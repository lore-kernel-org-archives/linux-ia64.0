From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 22 Feb 2022 13:43:25 +0000
Subject: Re: [PATCH 0/2] termbits.h cleanup
Message-Id: <YhTofdw8JhkKAt8c@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222115604.7351-1-ilpo.jarvinen@linux.intel.com>
In-Reply-To: <20220222115604.7351-1-ilpo.jarvinen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@linux.intel.com>
Cc: Jiri Slaby <jirislaby@kernel.org>, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org

On Tue, Feb 22, 2022 at 01:56:02PM +0200, Ilpo J=E4rvinen wrote:
> Two simple cleanup patches to termbits.h. I prefer these to go
> in through tty-next as I've some other work based on them that
> I'll submit later.
>=20
> Ilpo J=E4rvinen (2):
>   ia64: termbits.h is identical to asm-generic one
>   xtensa: termbits.h is identical to asm-generic one
>=20
>  arch/ia64/include/uapi/asm/termbits.h   | 209 ----------------------
>  arch/xtensa/include/uapi/asm/termbits.h | 221 ------------------------
>  2 files changed, 430 deletions(-)
>  delete mode 100644 arch/ia64/include/uapi/asm/termbits.h
>  delete mode 100644 arch/xtensa/include/uapi/asm/termbits.h
>=20
> --=20
> 2.30.2
>=20

Sure, I'll be glad to take them, thanks!

greg k-h
