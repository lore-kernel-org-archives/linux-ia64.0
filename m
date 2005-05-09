From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Mon, 09 May 2005 11:21:39 +0000
Subject: Re: [patch] fix HP simulator smp build replace __devinit -> __devinitdata (revised)
Message-Id: <20050509112139.GJ5692@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="NU0Ex4SbNnrxsi6C"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050509065711.GI5692@cse.unsw.EDU.AU>
In-Reply-To: <20050509065711.GI5692@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--NU0Ex4SbNnrxsi6C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith

On Mon, 09 May 2005, Keith Owens wrote:

> On Mon, 9 May 2005 16:57:11 +1000, 
> Darren Williams <dsw@gelato.unsw.edu.au> wrote:
> >Since we have updated the Autobuild system to use Cogito
> >we can start to report and submit patches on the latest
> >check-ins that break the build.
> >
> >Currently on the Gelato@UNSW Autobuild system:
> >http://www.gelato.unsw.edu.au/kerncomp/
> >we are seeing the sim_defconfig build fail, with the
> >following error:
> >
> >arch/ia64/kernel/smpboot.c:627: error: mt_info causes a section type conflict
> >
> >the following non-git patch fixes the problem, tested
> >on simulator, and zx1. I'm not sure why the simulator
> >is triggering this build failure since zx1 sn2 are
> >building OK?
> 
> __devinit is a no-op when CONFIG_HOTPLUG=y.  zx1 and sn2 configs enable
> HOTPLUG, sim_defconfig does not.
> 
> 
> That should be __devinitdata, not __initdata.

Revised patch, thanks Keith
Tested for compile and boot on zx1 and simulator. 

Signed-off-by:  Darren Williams <dsw@gelato.unsw.edu.au>


--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

--NU0Ex4SbNnrxsi6C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="smpboot.patch"

--- linux-2.6-orig/arch/ia64/kernel/smpboot.c	2005-05-09 16:29:30.000000000 +1000
+++ linux-2.6-import/arch/ia64/kernel/smpboot.c	2005-05-09 21:03:47.000000000 +1000
@@ -624,7 +624,7 @@
 	__u16   thread_id;
 	__u16   proc_fixed_addr;
 	__u8    valid;
-}mt_info[NR_CPUS] __devinit;
+}mt_info[NR_CPUS] __devinitdata;
 
 #ifdef CONFIG_HOTPLUG_CPU
 static inline void

--NU0Ex4SbNnrxsi6C--
