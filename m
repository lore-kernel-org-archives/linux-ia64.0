From: "ARADHYA, CHINMAYA TM (OpenView)" <chinmaya@hp.com>
Date: Tue, 01 Jun 2004 06:50:43 +0000
Subject: pthread_create() failing on ia64
Message-Id: <8BF7471D09AA9B4190A9C96778BC2A170143B265@qcaexc02.asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
 
A simple 32bit program with a pthread_create() call  when run on a ia64 system fails with an exception: pthread_create failed: errno
 
strace output shows clone(2) call failing:
 
...
clone(child_stack=0x40dd8b08, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID|CLONE_DETACHED, parent_tidptr=0x40dd8bf8, tls=0x40dd8bf8, child_tidptr=0xbffff684) = -1 EFAULT (Bad address)
...

The same program when built in 64bit mode runs fine. 
Can anybody let me know whether there is any patch which addresses this issue.
Ker Ver: 2.4.21-4.EL
Rels: RHAS 3.0

 
Many Thanks.
Chinmaya
