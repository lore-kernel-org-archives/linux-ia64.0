From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 05 May 2004 16:57:58 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <40991D16.F66CB173@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" wrote:

> >On Wed, May 05, 2004 at 10:53:10AM -0500, Mario Smarduch wrote:
> >> That's great but what release is that in?
> >
> >This is in 2.6.6-rc3.  I don't know when it was added.
>
> N.B. your test program will need some changes to work under
> 2.6 as the kernel is linked into virtual addresses in region 5
> instead of region 7.
>
> So "IDENBASE" and "jiffies - IDENBASE" would need to be changed.
>
> In fact there might be another whole layer of difficulty writing
> your test program, as figuring the physical address of the kernel
> object that you want to look at is a lot harder as the bootloader
> may have picked any physical address to load the kernel (though
> in practice at the moment it only does this on SGI sn2 machines).
>
> -Tony

Tony thanks for the pointers. I actually need to
have this work on 2.4 though.

