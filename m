From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 31 Jul 2003 20:28:57 +0000
Subject: Re: [PATCH] more discontig fun
Message-Id: <marc-linux-ia64-105968336018313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942849830042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942849830042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 31, 2003 at 09:10:06AM -0700, jbarnes wrote:
> On Wed, Jul 30, 2003 at 05:32:50PM -0700, David Mosberger wrote:
> > 
> >   Jesse> On Wed, Jul 30, 2003 at 10:17:13AM -0700, Jesse Barnes wrote:
> >   >> Ok, I'll fix this too.  Thanks for looking at it.
> > 
> >   Jesse> Does this look better?
> > 
> > Not really.
> > 
> >   Jesse> -efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
> >   Jesse> +efi_memmap_walk (efi_freemem_callback_t callback, void *arg, void *arg2)
> > 
> > Why is this necessary?  Why not just pack that extra argument into a
> > structure and pass the whole thing to "arg"?
> 
> Duh.  But now that I've gone through the exercise, it seems like the
> whole callback mechanism is a bit heavyweight (not to mention quite
> obtuse).  But I guess that's another patch...

Now that I look at this, I'm not quite sure what you'd like.  Would you
like all efi_memmap_walk calls to take a struct args with a function
pointer and argument or just filter_rsvd_memory?  Or would you like to
see it cleaned up in some other way?

Thanks,
Jesse
