From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 21 Dec 2006 05:03:47 +0000
Subject: Re: Unable to do IA64 stacktrace in early boot
Message-Id: <20061221050347.GT21070@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5478.1166673370@kao2.melbourne.sgi.com>
In-Reply-To: <5478.1166673370@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 21, 2006 at 02:56:10PM +1100, Keith Owens wrote:
>                     double unlock:  ok  |  ok  |failed|WARNING at /build/kaos/kernel.org-sgidev/linux/kernel/mutex-debug.c:83 debug_mutex_unlock()
> Unable to handle kernel NULL pointer dereference (address 0000000000000000)
> 
> mutex-debug uses DEBUG_LOCKS_WARN_ON() which indirectly calls
> dump_stack which the IA64 unwind code (arch/ia64/kernel/unwind.c) calls
> kmalloc.  The lockdep tests are run before the slab caches have been
> allocated so cpu_cache_get is called with a NULL cachep, hence the
> oops.

Yup.  I just debugged and fixed the same problem on parisc.  I didn't
think to check ia64; I checked to see what x86-64 did.  Unfortunately,
the ia64 unwind code seems a lot more subtle and more allocation-happy
than the parisc unwind code, so I'm not sure exactly how to fix ia64.

