From: Keith Owens <kaos@sgi.com>
Date: Mon, 09 May 2005 07:24:16 +0000
Subject: Re: [patch] fix HP simulator smp build replace __devinit -> __initdata
Message-Id: <6053.1115623456@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050509065711.GI5692@cse.unsw.EDU.AU>
In-Reply-To: <20050509065711.GI5692@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 9 May 2005 16:57:11 +1000, 
Darren Williams <dsw@gelato.unsw.edu.au> wrote:
>Since we have updated the Autobuild system to use Cogito
>we can start to report and submit patches on the latest
>check-ins that break the build.
>
>Currently on the Gelato@UNSW Autobuild system:
>http://www.gelato.unsw.edu.au/kerncomp/
>we are seeing the sim_defconfig build fail, with the
>following error:
>
>arch/ia64/kernel/smpboot.c:627: error: mt_info causes a section type conflict
>
>the following non-git patch fixes the problem, tested
>on simulator, and zx1. I'm not sure why the simulator
>is triggering this build failure since zx1 sn2 are
>building OK?

__devinit is a no-op when CONFIG_HOTPLUG=y.  zx1 and sn2 configs enable
HOTPLUG, sim_defconfig does not.

>--- linux-2.6-orig/arch/ia64/kernel/smpboot.c	2005-05-09 16:25:09.000000000 +1000
>+++ linux-2.6-import/arch/ia64/kernel/smpboot.c	2005-05-09 15:53:15.000000000 +1000
>@@ -624,7 +624,7 @@ static struct {
> 	__u16   thread_id;
> 	__u16   proc_fixed_addr;
> 	__u8    valid;
>-}mt_info[NR_CPUS] __devinit;
>+}mt_info[NR_CPUS] __initdata;

That should be __devinitdata, not __initdata.

