From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 18 Nov 2005 03:16:07 +0000
Subject: 2.6.14 boots on sgi altix?
Message-Id: <200511180316.jAI3G9g06785@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there something special I need to do to boot 2.6.14 on SGI
altix machine?  I took 7 day old 2.6.14.2 kernel source, and
did the following:

cp arch/ia64/config/sn2_defconfig .config
make oldconfig
make vmlinux

And it resulted with a bug check at very early stage of boot.
The boot log says:

Linux version 2.6.14.2 (root@linux-sgi) (gcc version 3.2.3 20030502 (Red Hat Linux 3.2.3-24)) #3 SMP Thu Nov 17 19:25:56 PST 2005
EFI v1.02 by SGI: SALsystab=0x3002514a60 ACPI 2.0=0x30027a1950
Number of logical nodes in system = 16
Number of memory chunks in system = 16
SAL 2.9: SGI SN2 version 4.4
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
No logical to physical processor mapping available
kernel BUG at arch/ia64/sn/kernel/setup.c:468!
swapper[0]: bugcheck! 0 [1]
....


2.6.12 boots just fine with the default sn2 config file.

