From: stefan <stefan@lkcc.org>
Date: Thu, 27 Sep 2001 07:31:25 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Sep 2001, David Mosberger wrote:

> >From this description, it sounds like you'd want to use swapcontext().
> I don't quite understand your pseudo-code though (what's are
> save_both_stacks()/restore_both_stacks() supposed to do?).
> 
> I do agree though that it would be nice to have a portable and
> thread-safe way of determining whether or not a getcontext() is
> returning for the first time.  On ia64, I made getcontext() return
> this information in register r9, but that's obviously not a portable
> solution.

Some more details about the pseudo code:

save_both_stacks:
  ucontext_t ctx;
  long size;
  void *backing_store, *stack;
  getcontext (&ctx);

  /* save backing store */
  size = ctx.uc_mcontext.sc_ar_bsp -
         __libc_ia64_resgister_backing_store_base;
  backing_store = malloc (size);
  memcpy (backing_store, __libc_ia64_register_backing_store_base, size);

  /* save stack */
  size = top_of_stack - (long) &ctx;
  stack = malloc (size);
  memcpy (stack, &ctx, size);

restore_both_stacks:
  /* does the opposite; puts the save data back onto same addresses */

Does this explain it better ?

I guess I can't just read r9 for the above purpose ?

Cheers,
	stefan@lkcc.org


