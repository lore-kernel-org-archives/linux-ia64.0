From: Vivek Goyal <vgoyal@redhat.com>
Date: Mon, 28 Jul 2008 13:31:10 +0000
Subject: Re: [patch] crashdump: fix undefined reference to `elfcorehdr_addr'
Message-Id: <20080728133110.GC25963@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au>
In-Reply-To: <20080728015117.GA12055@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Terry Loftin <terry.loftin@hp.com>, Tony Luck <tony.luck@intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-ia64@vger.kernel.org

On Mon, Jul 28, 2008 at 11:51:19AM +1000, Simon Horman wrote:
> [ Updated Vivek's email address to his vgoyal@redhat.com in CC list 
>   Added Terry Loftin, Tony Luck, Erik Biedermann and linux-ia64 to CC list ]
> 
> On Mon, Jul 28, 2008 at 09:45:31AM +1000, Simon Horman wrote:
> > > > diff --git a/include/linux/crash_dump.h b/include/linux/crash_dump.h
> > > > index 6cd39a9..025e4f5 100644
> > > > --- a/include/linux/crash_dump.h
> > > > +++ b/include/linux/crash_dump.h
> > > > @@ -8,7 +8,13 @@
> > > >  #include <linux/proc_fs.h>
> > > >  
> > > >  #define ELFCORE_ADDR_MAX	(-1ULL)
> > > > +
> > > > +#ifdef CONFIG_PROC_VMCORE
> > > >  extern unsigned long long elfcorehdr_addr;
> > > > +#else
> > > > +static const unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
> > > > +#endif
> > > > +
> > > >  extern ssize_t copy_oldmem_page(unsigned long, char *, size_t,
> > > >  						unsigned long, int);
> > > >  extern const struct file_operations proc_vmcore_operations;
> > > 
> > > spose that'll fix it.  But it seems odd that is_kdump_kernel() will
> > > return false if CONFIG_PROC_VMCORE=n, CONFIG_CRASH_DUMP=y.  I mean,
> > > it's still a crashdump kernel, is it not?
> > 
> > Perhaps is_kdump_kernel() ought to be renamed kernel_has_vmcore().
> > 
> > To my mind, is_kdump_kernel() should really look something like this:
> > 
> > #ifdef CONFIG_CRASH_DUMP
> > static inline int is_kdump_kernel(void) { return 1; }
> > #else
> > static inline int is_kdump_kernel(void) { return 0; }
> > #endif
> > 
> > But that can probably just be handled by any relevant code
> > using CONFIG_CRASH_DUMP as necessary.
> 
> Hi,
> 
> I started looking into a simple fix to change the name of
> the is_kdump_kernel() to kernel_has_vmcore(), which is what
> the code in its current incarnatation does.
> 
> This also lead to cleaning the usage of elfcorehdr_addr,
> which is in the folloing messy state after recent changes.
> 
> #ifdef CONFIG_PROC_VMCORE
> * Declared non-static include/linux/crash_dump.h
> * Initialised in fs/proc/vmcore.c
> #else
> * Declared and initialised as static in include/linux/crash_dump.h
> * Only used by is_kdump_kernel() which is a static function
>   also in include/linux/crash_dump.h
> #endif
> 
> 
> Howerver, in the course of doing this I came to thinking that actually
> this code won't solve the problem at hand in the case where
> CONFIG_CRASH_DUMP is defined but CONFIG_PROC_VMCORE is not.
> Or in other words, what happens if the calgary initialisation code
> runs in a kdump kernel that does not have CONFIG_PROC_VMCORE ?
> 
> A similar problem appears to exist in
> arch/ia64/hp/common/sba_iommu.c:sba_init(), which currently doesn't
> compile if CONFIG_CRASH_DUMP is set but CONFIG_PROC_VMCORE is not.  The
> compilation issue could be solved by using kernel_has_vmcore() (as per
> the patch below) instead of checking elfcorehdr_addr directly, but does
> it actually lead to working code?
> 
> There has long been a strong aversion to providing the second
> kernel with flags like im_in_kexec or im_in_kdump, as its felt
> that this kind of problem is better handled by making sure that the
> hardware is in a sensible state before leaving the first-kernel.
> But this is arguably more reasonable in the kexec case than the
> kdump case.
> 
> 
> If there really is a need for kdump kernels to know that they are
> booting a kdumping system, then I propose one of the following:
> 
> 1) Always parse the elfcorehdr kernel command line option
>    and set elfcorehdr_addr accordingly - currently this is only
>    done if CONFIG_PROC_VMCORE is set.
> 
>    This is nice as it won't need any modifications to kexec-tools
>    nor any command line bloat.
> 
>    A minor difficulty is working out where to initialise elfcorehdr_addr.
>    Sometimes in include/linux/crash_dump.h and sometimes in
>    fs/proc/vmcore.c seems horrible to me.
> 
>    Another problem is that would be alive and well in
>    code that really only uses it to check if kdump was activated or not
>    - a minor naming issue.
> 

Hi Simon,

There are some kernel bits (like iommu initialization patch), which need to
take special action if they are booting after a kexec on panic (Generally we
are referring it to booting into kdump kernel) and that's why the notion
is_kdump_kernel().

To me, is_kdump_kernel() symbolizes whether I  am booting after kexec on
panic and not just the fact if CONFIG_CRASH_DUMP is enabled or not in this
kernel.

So I would think that lets not rename it to kernel_has_vmcore(), instead
lets write few lines of comments before function is_kdump_kernel() to
clarify its meaning.

Secondly, we are using elfcorehdr_addr to determine whether this kernel
is booting after a panic so elfcorehdr_addr is not just limited to
CONFIG_PROC_VMCORE now and we should probably pull it out of
fs/proc/vmcore.c. How about declaring and initializing this variable in
kernel/kexec.c under CONFIG_CRASH_DUMP and always parse elfcorehdr_addr
irrespective of the setting of CONFIG_PROC_VMCORE?

> 2) Add a new kernel command line option, perhaps in_kdump
> 
>    This is bloat to get around elfcorehdr_addr initialisation and
>    naming awkwardness above.
> 
> 3) Make select CONFIG_PROC_VMCORE when CONFIG_CRASH_DUMP is selected,
>    or perhaps even just remove CONFIG_PROC_VMCORE and only use
>    CONFIG_CRASH_DUMP instead. The effect would be the same either way.
> 
>    Pro: One less thing to be confused about
> 
>    Con: Bloat for people who want kdump without vmcore.
>         I wonder what usage case that is.

Argument was people can use /dev/oldmem and not use /proc/vmcore. So far
I don't know anybody who uses /dev/oldmem to capture dump and not
/proc/vmcore.

Thanks
Vivek
