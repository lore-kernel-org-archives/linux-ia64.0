From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 16 Oct 2002 07:56:16 +0000
Subject: Re: [Linux-ia64] Re: loading a kernel module
Message-Id: <marc-linux-ia64-105590709805172@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805162@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805162@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens schrieb:

> On Wed, 16 Oct 2002 07:52:15 +0200,
> Christian Hildner <christian.hildner@hob.de> wrote:
> >the source isn't that complex as you might have seen in the length of the objdump output.
> >The object I have given you is only a small test program to find out the missing linkage for
> >brl branches. My original program needs brl to branch across virtual pages with a big
> >difference in the virtual addresses. So the test prog never makes any sence, but shows the
> >missing R_IA64_PCREL60B nicely.
> >
> >Christian
> >
> >PS: Here is the source without any guarantee not to crash ...
> >
> >#define MODULE
> >#include <linux/module.h>
> >
> >int dummy(void)
> >{
> >    return 0;
> >}
> >
> >int init_module(void)
> >{
> >    printk("Init Module starting. About to crash...\n");
> >    asm volatile ("brl dummy ");
> >    return 0;
> >}
> >
> >void cleanup_module(void)
> >{
> >    printk("Done\n");
> >}
>
> OK, so it is not a toolchain problem, this is user code.  Unfortunately
> it is introducing a special case into modutils.
>
> All existing PCREL relocations in modutils go via a PLT, saving and
> switching GP as they do so.  I am assuming that branching via the PLT
> is no good for you, you really do want a direct branch over the 64 bit
> address space, without any change to GP.  That is, the source and
> target addresses use the same global data area, or one of them does not
> use any global data area at all.  Please confirm this before I make any
> changes.
>
> If you need different GP values in the source and target addresses then
> a normal PCREL21 via PLT will do the job.

What I want to do is a simple branch without any side effects like adjusting GP. I am doing a
branch like brl (local_label + PAGE_OFFSET) where PAGE_OFFSET is the distance between the two
"shadowed" pages. Maybe there is a way to tell the compiler/assembler not to make a linkage entry
for that branch. There is no addressing of any data segment by the means of GP in my program.

Christian


