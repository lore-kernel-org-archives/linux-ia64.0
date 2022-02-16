From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 16 Feb 2022 18:41:09 +0000
Subject: Re: [PATCH v2 15/18] sparc64: remove CONFIG_SET_FS support
Message-Id: <Yg1FRZcrhlh5C//V@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-16-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-16-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Arnd,

On Wed, Feb 16, 2022 at 07:34:59PM +0100, Sam Ravnborg wrote:
> Hi Arnd.
> 
> On Wed, Feb 16, 2022 at 02:13:29PM +0100, Arnd Bergmann wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > 
> > sparc64 uses address space identifiers to differentiate between kernel
> > and user space, using ASI_P for kernel threads but ASI_AIUS for normal
> > user space, with the option of changing between them.
> > 
> > As nothing really changes the ASI any more, just hardcode ASI_AIUS
> > everywhere. Kernel threads are not allowed to access __user pointers
> > anyway.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  arch/sparc/include/asm/processor_64.h   |  4 ----
> >  arch/sparc/include/asm/switch_to_64.h   |  4 +---
> >  arch/sparc/include/asm/thread_info_64.h |  4 +---
> >  arch/sparc/include/asm/uaccess_64.h     | 20 +-------------------
> >  arch/sparc/kernel/process_64.c          | 12 ------------
> >  arch/sparc/kernel/traps_64.c            |  2 --
> >  arch/sparc/lib/NGmemcpy.S               |  3 +--
> >  arch/sparc/mm/init_64.c                 |  7 ++++---
> >  8 files changed, 8 insertions(+), 48 deletions(-)
> 
> I think you somehow missed the Kconfig change, and also the related
> sparc32 change which continue to have set_fs() after this patch.
I now notice the sparc32 bits are in the last patch.
To avoid breaking bisect-ability on sparc64 I think you need to merge
the sparc32 changes with this patch, unless the sparc64 changes can
coexist with CONFIG_SET_FS continue to be set.

	Sam
