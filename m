From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 21 Dec 2006 22:03:00 +0000
Subject: Re: Unable to do IA64 stacktrace in early boot
Message-Id: <ed5aea430612211403p63d0c28ds341a2d9cf9be5c62@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5478.1166673370@kao2.melbourne.sgi.com>
In-Reply-To: <5478.1166673370@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The libunwind-based unwinder uses it's own primitive allocator to
avoid such problems.  I posted a working patch a couple of months
back.

  --david

On 12/21/06, Ingo Molnar <mingo@redhat.com> wrote:
> On Wed, 2006-12-20 at 22:03 -0700, Matthew Wilcox wrote:
> > > mutex-debug uses DEBUG_LOCKS_WARN_ON() which indirectly calls
> > > dump_stack which the IA64 unwind code (arch/ia64/kernel/unwind.c)
> > calls
> > > kmalloc.  The lockdep tests are run before the slab caches have been
> > > allocated so cpu_cache_get is called with a NULL cachep, hence the
> > > oops.
> >
> > Yup.  I just debugged and fixed the same problem on parisc.  I didn't
> > think to check ia64; I checked to see what x86-64 did.  Unfortunately,
> > the ia64 unwind code seems a lot more subtle and more allocation-happy
> > than the parisc unwind code, so I'm not sure exactly how to fix ia64.
>
> yeah. calling kmalloc() within the unwinder is a no-no. What if the
> unwind happens while kmalloc() is crashing?
>
>         Ingo
> >
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
