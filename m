From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 05 May 2004 15:53:10 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <40990DE6.72969C72@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:

> On Wed, May 05, 2004 at 08:08:21AM -0700, Luck, Tony wrote:
> > Mapping kernel memory as uncacheable into a user process
> > seems like a recipe for disaster (well at least for an
> > MCA when the processor catches you using mixed attributes).
>
> ... which is why we don't do that.
>
> See drivers/char/mem.c::mmap_mem().  We call uncached_access() which does:
>
> #elif defined(CONFIG_IA64)
>         /*
>          * On ia64, we ignore O_SYNC because we cannot tolerate memory attribute
> aliases.
>          */
>         return !(efi_mem_attributes(addr) & EFI_MEMORY_WB);

That's great but what release is that in?

- mario.

>
>
> --
> "Next the statesmen will invent cheap lies, putting the blame upon
> the nation that is attacked, and every man will be glad of those
> conscience-soothing falsities, and will diligently study them, and refuse
> to examine any refutations of them; and thus he will by and by convince
> himself that the war is just, and will thank God for the better sleep
> he enjoys after this process of grotesque self-deception." -- Mark Twain
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

