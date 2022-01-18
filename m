From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Jan 2022 08:08:41 +0000
Subject: Re: [PATCH 2/3] vstatus: Add user space API definitions for VSTATUS, NOKERNINFO and TIOCSTAT
Message-Id: <CAK8P3a0ohW+w8_A8qMNqxpTmFcvxQr+z9YR96RAu5-wtdG_5+g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220118044323.765038-1-walt@drummond.us> <20220118044323.765038-2-walt@drummond.us>
In-Reply-To: <20220118044323.765038-2-walt@drummond.us>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Walt Drummond <walt@drummond.us>
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Yoshinori Sato <ysato@users.osdn.me>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, ar@cs.msu.ru, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, alpha <linux-alpha@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-arch <linux-arch@vger.kernel.org>

On Tue, Jan 18, 2022 at 5:43 AM Walt Drummond <walt@drummond.us> wrote:

> diff --git a/include/uapi/asm-generic/ioctls.h b/include/uapi/asm-generic/ioctls.h
> index cdc9f4ca8c27..eafb662d6a0e 100644
> --- a/include/uapi/asm-generic/ioctls.h
> +++ b/include/uapi/asm-generic/ioctls.h
> @@ -97,6 +97,7 @@
>
>  #define TIOCMIWAIT     0x545C  /* wait for a change on serial input line(s) */
>  #define TIOCGICOUNT    0x545D  /* read serial port inline interrupt counts */
> +#define TIOCSTAT        0x545E /* display process group stats on tty */
>
>  /*
>   * Some arches already define FIOQSIZE due to a historical

I don't see any advantage in using the old-style ioctl command definitions
here, and looking through the history of this file, all recent additions used
the now normal _IOWR() style macros, so please use those as well.

       Arnd
