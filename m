From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Mon, 09 May 2005 06:57:11 +0000
Subject: [patch] fix HP simulator smp build replace __devinit -> __initdata
Message-Id: <20050509065711.GI5692@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="1UWUbFP1cBYEclgG"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--1UWUbFP1cBYEclgG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Since we have updated the Autobuild system to use Cogito
we can start to report and submit patches on the latest
check-ins that break the build. 

Currently on the Gelato@UNSW Autobuild system:
http://www.gelato.unsw.edu.au/kerncomp/
we are seeing the sim_defconfig build fail, with the
following error:

arch/ia64/kernel/smpboot.c:627: error: mt_info causes a section type conflict

the following non-git patch fixes the problem, tested
on simulator, and zx1. I'm not sure why the simulator
is triggering this build failure since zx1 sn2 are
building OK?

 - dsw

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

--1UWUbFP1cBYEclgG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="smpboot.patch"

--- linux-2.6-orig/arch/ia64/kernel/smpboot.c	2005-05-09 16:25:09.000000000 +1000
+++ linux-2.6-import/arch/ia64/kernel/smpboot.c	2005-05-09 15:53:15.000000000 +1000
@@ -624,7 +624,7 @@ static struct {
 	__u16   thread_id;
 	__u16   proc_fixed_addr;
 	__u8    valid;
-}mt_info[NR_CPUS] __devinit;
+}mt_info[NR_CPUS] __initdata;
 
 #ifdef CONFIG_HOTPLUG_CPU
 static inline void

--1UWUbFP1cBYEclgG--
