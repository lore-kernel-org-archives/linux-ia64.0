From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Wed, 26 Apr 2006 10:27:54 +0000
Subject: Re: [PATCH] change gen_pool allocator to not touch managed memory
Message-Id: <9a8748490604260327pe936e87yc9105868cc14557a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com>
	 <20060424181626.09966912.akpm@osdl.org>
	 <20060425155051.GA19248@sgi.com>
In-Reply-To: <20060425155051.GA19248@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, jes@sgi.com, avolkov@varma-el.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 4/25/06, Dean Nelson <dcn@sgi.com> wrote:
> The following patch modifies the gen_pool allocator (lib/genalloc.c) to
> utilize a bitmap scheme instead of the buddy scheme. The purpose of this
> change is to eliminate the touching of the actual memory being allocated.
>
> Since the change modifies the interface, a change to the uncached
> allocator (arch/ia64/kernel/uncached.c) is also required.
>
[snip]

A few small comments below.

> -unsigned long gen_pool_alloc(struct gen_pool *poolp, int size)
> +int gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size,
> +                int nid)
>  {
> -       int j, i, s, max_chunk_size;
> -       unsigned long a, flags;
> -       struct gen_pool_link *h = poolp->h;
> +       struct gen_pool_chunk *chunk;
> +       int nbits = size >> pool->min_alloc_order;
> +       int nbytes = sizeof(struct gen_pool_chunk) +
> +                               (nbits + BITS_PER_BYTE - 1) / BITS_PER_BYTE;
> +
> +       if (nbytes > PAGE_SIZE) {
> +               chunk = vmalloc_node(nbytes, nid);
> +       } else {
> +               chunk = kmalloc_node(nbytes, GFP_KERNEL, nid);
> +       }

No curly braces when not needed is usually prefered.

       if (nbytes > PAGE_SIZE)
               chunk = vmalloc_node(nbytes, nid);
       else
               chunk = kmalloc_node(nbytes, GFP_KERNEL, nid);


> +static int
> +uncached_add_chunk(struct gen_pool *pool, int nid)

Why not

 +static int uncached_add_chunk(struct gen_pool *pool, int nid)

There's room for it on one line and other functions in that file use
just one line (more grep'able)...


>  void
> -uncached_free_page(unsigned long maddr)
> +uncached_free_page(unsigned long uc_addr)

Move this to a single line perhaps?

 +void uncached_free_page(unsigned long uc_addr)


> +static int __init
> +uncached_init(void)

One line ?


--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
