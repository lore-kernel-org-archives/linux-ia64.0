From: Andrew Morton <akpm@osdl.org>
Date: Mon, 14 Jun 2004 07:29:31 +0000
Subject: Fw: [Bugme-new] [Bug 2885] New: realtime process can't preempt low
Message-Id: <20040614002931.00b846a4.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This would appear to indicate that CONFIG_PREEMPT isn't working
correctly on ia64.


Begin forwarded message:

Date: Mon, 14 Jun 2004 00:25:22 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2885] New: realtime process can't preempt low priority process in kernel


http://bugme.osdl.org/show_bug.cgi?id(85

           Summary: realtime process can't preempt low priority process in
                    kernel
    Kernel Version: 2.6.5
            Status: NEW
          Severity: normal
             Owner: rml@tech9.net
         Submitter: hong.liu@intel.com
                CC: yi.zhu@intel.com


Distribution:
Hardware Environment: 4 Itanium2 1.4G processors-tiger4
Software Environment: gcc-3.3.3
Problem Description:

After turning on the CONFIG_PREEMPT option and recompile the kernel source 
code, the realtime process still can't preempt the low priority process which 
is doing busy loop in kernel. 
The test case does pass both on a pentium 4 PC and a Xeon 2.4G smp machine.

Steps to reproduce:
in the directory of the test case, 
#make
#insmod ./modules/hog.ko
#mknod /dev/hog c 126 0
#./do_hog

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
