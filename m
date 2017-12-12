From: Joe Perches <joe@perches.com>
Date: Tue, 12 Dec 2017 03:10:52 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <1513048252.3036.23.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <1513009569.26342.43.camel@perches.com>
 <20171212024757.GC7798@jagdpanzerIV>
In-Reply-To: <20171212024757.GC7798@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, 2017-12-12 at 11:47 +0900, Sergey Senozhatsky wrote:
> On (12/11/17 08:26), Joe Perches wrote:
> > On Mon, 2017-12-11 at 21:50 +0900, Sergey Senozhatsky wrote:
> > > print_symbol
> > Yay.
> > Just about exactly 5 years earlier...
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2012-December/137121.html
> 
> indeed :)
> 
> hopefully it won't take us another 5 years to finally
[]
> diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
[]
> -static inline void print_symbol(const char *fmt, unsigned long addr)
> +static inline void __deprecated print_symbol(const char *fmt,
> +					     unsigned long addr)
>  {
>  	__check_printsym_format(fmt, "");
>  	__print_symbol(fmt, (unsigned long)

As far as I'm concerned, as soon as there is
no longer a single user in the kernel tree,
better to delete it instead.


