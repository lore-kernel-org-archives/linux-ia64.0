From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 09 Jan 2001 23:03:11 +0000
Subject: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590678205904@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I try booting the new kernel on a 2xB3 BigSur running BIOS 89 I get
the following kernel panic:

     VFS: Mounted root (ext2 filesystem) readonly.
     Freeing unused kernel memory: 352kB freed
     Unable to handle kernel paging request at virtual address
     2000000000044008
     init[1]: Oops 8813272891392
     psr : 0000101008026030 ifs : 8000000000000185 ip  :
     [<e000000000500820>]
     ...
     Kernel panic: Attempted to kill init!

The IP points inside the dtlb_fault code.  Any ideas what's going on
here?  The panic happens both with SMP and UP kernels.  I have disabled
the VHPT (CONFIG_DISABLE_VHPT=y).  Anything else I am missing?

Thanks,
Uros

--
Uros Prestor
uros@turbolinux.com




