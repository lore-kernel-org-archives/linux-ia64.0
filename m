From: Andrew Morton <akpm@osdl.org>
Date: Fri, 08 Apr 2005 18:02:47 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <20050408110247.21be2eb7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt Mackall <mpm@selenic.com> wrote:
>
> One wonders if:
> 
>   return ia64_getf_exp(d) & 0x3f;
> 
>  is the right fix.

Yes, that'll give the right result for fls(-1).  But what'll it give for
fls(-2)?

> The fact that it's using floating point is... weird.
> 
>  Work around broken IA64 fls.

I'd be more inclined to make ia64 use generic_fls() until someone can get
in there and fix it for real.



