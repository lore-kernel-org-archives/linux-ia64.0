From: Meelis Roos <mroos@linux.ee>
Date: Sun, 11 Mar 2018 10:25:23 +0000
Subject: Can not boot rx1600, rx1620, rx2800 - at all
Message-Id: <alpine.LRH.2.21.1803111219540.27692@math.ut.ee>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linux is working fine on my RX2620 and RX2660. However, on RX1600, 
RX1620 and RX2800, the kernel reboots before displaying anything at all:

Uncompressing Linux... done
Loading file initrd.gz...done
1,1,0,0 5400006341E10000 0000000000000000 EVN_BOOT_START                        
***********************************************************
* ROM Version : 01.95
* ROM Date    : Fri Feb 01 03:54:28 PST 2013
***********************************************************
1,1,0,0 3400083741E10000 000000000002000C EVN_BOOT_CELL_JOINED_PD               
1,0,0,0 540026FC01E10000 00000000000F000C EVN_SFW_INITIATED_RESET               
1,1,0,0 5400006341E10000 0000000000000000 EVN_BOOT_START                        

On RX1600, I had an ancient Debian distro kernel working when this was 
the current kernel and ia64 was supported by Debian. However, I have 
been unable to compile any kernels successfully for the problematic machines.

Same kernel image that boots RX2620 reboots on RX1600.

Any idea where I could start digging? How do I put some output in 
startup code before prontk works (and where is that code on ia64)?

-- 
Meelis Roos (mroos@linux.ee)
