From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 08 Jan 2019 13:40:18 +0000
Subject: Re: [PATCH v3 7/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CAF=yD-Jy7kyNtae7QpHgn6kJtmmYCngNdzF3K5DqVJBTHOUfqA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190108032657.8331-1-deepa.kernel@gmail.com> <20190108032657.8331-8-deepa.kernel@gmail.com>
In-Reply-To: <20190108032657.8331-8-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>, Chris Zankel <chris@zankel.net>, fenghua.yu@intel.com, rth@twiddle.net, Thomas Gleixner <tglx@linutronix.de>, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux <sparclinux@vger.kernel.org>

On Mon, Jan 7, 2019 at 10:29 PM Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> Add SO_TIMESTAMPING_NEW variant of socket timestamp options.
> This is the y2038 safe versions of the SO_TIMESTAMPING_OLD
> for all architectures.
>
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: chris@zankel.net
> Cc: fenghua.yu@intel.com
> Cc: rth@twiddle.net
> Cc: tglx@linutronix.de
> Cc: ubraun@linux.ibm.com
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-mips@linux-mips.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: sparclinux@vger.kernel.org
> ---

> --- a/arch/sparc/include/uapi/asm/socket.h
> +++ b/arch/sparc/include/uapi/asm/socket.h
> @@ -106,20 +106,22 @@
>  #define SO_TIMESTAMPNS_OLD       0x0021
>  #define SO_TIMESTAMPING_OLD      0x0023
>
> -#define SO_TIMESTAMP_NEW         0x0040
> -#define SO_TIMESTAMPNS_NEW       0x0041
> +#define SO_TIMESTAMP_NEW         0x0041
> +#define SO_TIMESTAMPNS_NEW       0x0042
> +#define SO_TIMESTAMPING_NEW      0x0043

nit: unnecessary? perhaps need to get indentation consistent
immediately in the previous patch in this series that introduces
SO_TIMESTAMP_NEW
