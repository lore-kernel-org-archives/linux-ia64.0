From: Mike Becher <Mike.Becher@lrz-muenchen.de>
Date: Fri, 06 Aug 2004 11:29:55 +0000
Subject: ptrace problem on ia64 with kernel 2.4.26 (second)
Message-Id: <Pine.LNX.4.58.0408061155470.19996@lxmbe01.lrz.lrz-muenchen.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

on our Linux IA64 cluster (17 nodes) we got the problem that tools like 
strace, gdb, ddd, and other debugging tools, which depend on ptrace system 
call, don't work after some days of uptime of a node. I have searched 
already in the web about information relating to that problem but haven't 
found any answer.

description:
------------
On a node that got the problem (perhaps it runs longer than 3 days) strace 
produce this output:
  [mibe@lxsrv154]# strace /bin/true
  execve("/bin/true", ["/bin/true"], [/* 38 vars */]) = 0
  upeek: ptrace(PTRACE_PEEKUSER, ... ): Input/output error
Instead on a `younger' node or fresh booted node strace works fine.

comment:
--------
Yesterday I have sent this massage to linux-kernel mailing list. But 
meanwhile we have determined that Intel's debugger `idb' works on both
kind of nodes. You can check the content of register r4, r5, and so on 
while gdb and the other tools don't work anymore. It might be that `idb' 
uses another way to get the register values than gdb on Linux-IA64.

more description:
-----------------
To find out what is differnt I have used also the `utrace' tool
(http://www.gelato.unsw.edu.au/IA64wiki/utrace) with a small
modification to peek info about register r4.

diff utrace.c.orig utrace.c
62c62
<   long scnum, result, error, val;
---
>   long scnum, result, result_r4, error, val;
74a75
>   result_r4 = ptrace (PTRACE_PEEKUSER, child_pid, PT_R4, 0);

With this register starts the critical area of ptrace for debuggers
when problem exists. They all don't do their work because they cannot
gather information about some registers like r4, r5, r6, r7.
Also it doesn't work for user `root'.
Whether in messages files nor in /proc filesystem nor with dmesg I
have found any info that can give me a hint what has changed. 

configuration:
--------------
We use the following configuration:
* kernel 2.4.26 (vanilla kernel) with 
  - official linux-2.4.26-ia64-040510.diff.bz2 (11-May-2004 11:18)
  - EXPORT_SYMBOL_NOVERS(iosapic_fixup_pci_interrupt) in
    linux-2.4.26/arch/ia64/kernel/ia64_ksyms.c
  - commented out 
     printk(KERN_WARNING "%s(%d): floating-point assist...)
    in linux-2.4.26/arch/ia64/kernel/traps.c
  - BitKeeper patch which fixes x86 "clear_cpu()" macro.
    on line 34 to >>> asm volatile("fnclex ; fwait");
* openafs 1.2.11
* Myrinet driver GM build ID is "1.6.4_Linux_and_AIX
* PVFS 1.6.2 with pvfs-1.6.2-01292004.patch
* following modules are loaded:
  [mibe@lxsrv154 ia64]# lsmod
  Module                  Size  Used by    Tainted: PF
  pvfs                  147336   7
  imb                    43024   0
  gm                    620176   1  (autoclean)
  libafs-2.4.26.mp     1296528   2
  e1000                 170976   1
  nls_iso8859-1           6000   1  (autoclean)
  nls_cp437               7680   1  (autoclean)
  usbkbd                  9040   0  (unused)
  ehci-hcd               54872   0  (unused)
  usb-uhci               66888   0  (unused)
  usbcore               182800   1  [usbkbd ehci-hcd usb-uhci]
  aacraid                95512   7
  sd_mod                 33856  14

Hope someone can help me to solve this problem.

best regards,
  Mike
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
