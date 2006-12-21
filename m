From: Ingo Molnar <mingo@redhat.com>
Date: Thu, 21 Dec 2006 14:44:04 +0000
Subject: Re: Unable to do IA64 stacktrace in early boot
Message-Id: <1166712244.8869.18.camel@earth>
List-Id: <linux-ia64.vger.kernel.org>
References: <5478.1166673370@kao2.melbourne.sgi.com>
In-Reply-To: <5478.1166673370@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-12-20 at 22:03 -0700, Matthew Wilcox wrote:
> > mutex-debug uses DEBUG_LOCKS_WARN_ON() which indirectly calls
> > dump_stack which the IA64 unwind code (arch/ia64/kernel/unwind.c)
> calls
> > kmalloc.  The lockdep tests are run before the slab caches have been
> > allocated so cpu_cache_get is called with a NULL cachep, hence the
> > oops.
> 
> Yup.  I just debugged and fixed the same problem on parisc.  I didn't
> think to check ia64; I checked to see what x86-64 did.  Unfortunately,
> the ia64 unwind code seems a lot more subtle and more allocation-happy
> than the parisc unwind code, so I'm not sure exactly how to fix ia64.

yeah. calling kmalloc() within the unwinder is a no-no. What if the
unwind happens while kmalloc() is crashing?

	Ingo
> 

