From: n0ano@indstorage.com
Date: Mon, 12 Nov 2001 15:28:52 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hideki-

A couple of points:

1)  It turns out that IA32 programs have all sorts of hidden
assumptions that a page size is 4K.  Changing `__getpagsize'
to return the true page size might fix your problem but I
predict that such a change would break many other programs.
I'll look at your test case and see if there is anything we
can do.

2)  If all else fails you can run your IA64 machine with a
4K page size.  We've always said that, for true complete IA32
support, you may have to run with 4K pages.  I've put a lot of
effort into allowing larger page sizes for `normal' prgrams,
yours might be one that requires a 4K kernel.

3)  I'm just curious, is this a real application or is this
just a test case?

On Mon, Nov 12, 2001 at 05:15:53PM +0900, Hideki Yamamoto wrote:
> 
>  Hello all.
> 
>  If this problem has already known, I am sorry.
> 
>  I am investigating the problem that calloc returns no
>  cleared area.
>  It was made on IA32 system and executes on IA64.
>  I think calloc expects to clear the memories sbrk
>  returned. But When the program made on IA32 is
>  executing on IA64 system, sbrk sometimes returns no
>  cleared area. 
>  Because the Kernel on IA64 alignes the memories 16K
>  bytes. However, when the progmam made on IA32 is
>  executing on IA64, the function __getpagesize returns
>  4Kbytes. At this case, if the memories that calloc
>  requests to return sbrk(-xxx) is smaller than
>  16Kbytes, the kernel do not unmap this memory.
>  (I think that the time that the memories clears 0 by
>  the kernel is when the kernel maps memories by the signal) 
> 
>  How do you think?
> 
> --
> Regards, 
> Hideki Yamamoto   (V).v.(V) # Empowered by Innovation
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

