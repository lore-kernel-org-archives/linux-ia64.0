From: Robin Holt <holt@sgi.com>
Date: Thu, 21 Aug 2008 13:04:23 +0000
Subject: Re: linux-next: ia64 allmodconfig
Message-Id: <20080821130423.GB8051@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 21, 2008 at 07:59:58AM -0500, Robin Holt wrote:
> On Wed, Aug 20, 2008 at 11:35:26PM -0700, Andrew Morton wrote:
> > arch/ia64/kernel/built-in.o(.text+0x4862): In function `efi_initialize_iomem_resources':
> > : undefined reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x12a92): In function `pfm_context_create':
> > : undefined reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x1bc02): In function `sys_perfmonctl':
> > : undefined reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x37c82): In function `dup_state_stack':
> > : undefined reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x382b2): In function `desc_prologue':
> > : undefined reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x3ad12): more undefined references to `__ia64_save_stack_nonlocal' follow
> > 
> > ia64 seems to break a lot.
> 
> I just did a git-checkout of
> git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git
>  linux-next/master and got commit:
> e85df409b2ad8528fa772379393c81406c417bbf
> 
> When I
> make allmodconfig; make -j 24 compressed, I get no such warnings.  I do
> still see a failure from the SFC driver :(
> 
> Are you sure something isn't a little dirty in your work area?  Did you
> maybe do a make allyesconfig, allnoconfig, allmodconfig sequence?

Oh, just realized this could be a gcc version issue as well.  Could you
provide that as well?  I had used the SLES installed version (4.1.2).

Thanks,
Robin
