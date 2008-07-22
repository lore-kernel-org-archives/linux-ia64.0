From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 22 Jul 2008 10:05:06 +0000
Subject: Re: [PATCH] Make u64 long long on all architectures (was: the
Message-Id: <20080722030506.206a2cc2.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com>
	<20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<20080704132716.f1e12554.akpm@linux-foundation.org>
	<20080704204252.GM14894@parisc-linux.org>
	<20080704150100.1f7b8a65.akpm@linux-foundation.org>
	<20080705020350.GN14894@parisc-linux.org>
In-Reply-To: <20080705020350.GN14894@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

On Fri, 4 Jul 2008 20:03:51 -0600 Matthew Wilcox <matthew@wil.cx> wrote:

> [PATCH] Make u64 long long on all architectures
> 
> It is currently awkward to print a u64 type.  Some architectures use
> unsigned long while others use unsigned long long.  Since unsigned long
> long is 64-bit for all existing Linux architectures, change those that
> use long to use long long.  Note that this applies only within the
> kernel.  If u64 is being used in a C++ method definition, the symbol
> mangling would change.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> 
> diff --git a/include/asm-generic/int-l64.h b/include/asm-generic/int-l64.h
> index 2af9b75..32f07bd 100644
> --- a/include/asm-generic/int-l64.h
> +++ b/include/asm-generic/int-l64.h
> @@ -23,8 +23,13 @@ typedef unsigned short __u16;
>  typedef __signed__ int __s32;
>  typedef unsigned int __u32;
>  
> +#ifdef __KERNEL__
> +typedef __signed__ long long __s64;
> +typedef unsigned long long __u64;
> +#else
>  typedef __signed__ long __s64;
>  typedef unsigned long __u64;
> +#endif
>  
>  #endif /* __ASSEMBLY__ */

This is (IMO) a desirable change and will prevent a heck of a lot of
goofing around, and will permit a lot of prior goofing around to
be removed.

But I bet there are lots of instalces of printk("%l", some_u64) down in
arch code where the type of u64 _is_ known which will now spew warnings.

Oh well.
