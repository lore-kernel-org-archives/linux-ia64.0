From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Wed, 20 Dec 2017 10:20:34 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20171220102034.GG11774@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (12/11/17 21:50), Sergey Senozhatsky wrote:
> 
> 	A rather automatic replacement of print_symbol()
> with direct printk() calls. print_symbol() uses extra stack
> buffer (KSYM_SYMBOL_LEN 128 bytes) and, basically, should
> be identical to printk(%pS).
> 
> 	I can't test all of the patches, because I don't
> own any of those exotic arch-s. Sorry for the inconvenience.
> 
> Sergey Senozhatsky (13):
>   arm: do not use print_symbol()
>   arm64: do not use print_symbol()
>   c6x: do not use print_symbol()
>   ia64: do not use print_symbol()
>   mn10300: do not use print_symbol()
>   sh: do not use print_symbol()
>   unicore32: do not use print_symbol()
>   x86: do not use print_symbol()
>   drivers: do not use print_symbol()
>   sysfs: do not use print_symbol()
>   irq debug: do not use print_symbol()
>   lib: do not use print_symbol()
>   arc: do not use __print_symbol()

Hello,

can we please have more reviews/acks/etc?

	-ss
