From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 18 May 2018 08:30:24 +0000
Subject: Re: [PATCH 4.9 27/33] futex: Remove duplicated code and fix undefined behaviour
Message-Id: <e8dc5f94-3b52-dcf0-3b5e-b442bde7d803@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180518081535.096308218@linuxfoundation.org>
 <20180518081536.166573281@linuxfoundation.org>
In-Reply-To: <20180518081536.166573281@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Russell King <rmk+kernel@armlinux.org.uk>, "Darren Hart (VMware)" <dvhart@infradead.org>, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Catalin Marinas <catalin.marinas@arm.com>, Matt Turner <mattst88@gmail.com>, linux-snps-ar

On 05/18/2018, 10:16 AM, Greg Kroah-Hartman wrote:
> 4.9-stable review patch.  If anyone has any objections, please let me kno=
w.
>=20
> ------------------
>=20
> From: Jiri Slaby <jslaby@suse.cz>
>=20
> commit 30d6e0a4190d37740e9447e4e4815f06992dd8c3 upstream.
...
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -1458,6 +1458,45 @@ out:
>  	return ret;
>  }
> =20
> +static int futex_atomic_op_inuser(unsigned int encoded_op, u32 __user *u=
addr)
> +{
> +	unsigned int op =3D	  (encoded_op & 0x70000000) >> 28;
> +	unsigned int cmp =3D	  (encoded_op & 0x0f000000) >> 24;
> +	int oparg =3D sign_extend32((encoded_op & 0x00fff000) >> 12, 12);
> +	int cmparg =3D sign_extend32(encoded_op & 0x00000fff, 12);

12 is wrong here =E2=80=93 wherever you apply this, you need also a follow-=
up fix:
commit d70ef22892ed6c066e51e118b225923c9b74af34
Author: Jiri Slaby <jslaby@suse.cz>
Date:   Thu Nov 30 15:35:44 2017 +0100

    futex: futex_wake_op, fix sign_extend32 sign bits

thanks,
--=20
js
suse labs
