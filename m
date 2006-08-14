From: Bob Montgomery <bob.montgomery@hp.com>
Date: Mon, 14 Aug 2006 21:24:57 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155590697.26951.196.camel@amd.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
> This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.

Contrary to expectations, my experience with this patch on a 2.6.18-rc4
kernel is that kexec -l, kexec -e is now working without my adding any
delays to mptscsih, and the kexec -p, echo c >/proc/sysrq-trigger case
hangs.

My "got here" printk's on the console indicate:

SysRq : Trigger a crashdump
machine_crash_shutdown
device_shootdown
machine_kexec type: 1

And then it hangs.

My test system: hp A6870A server rx2600
From /proc/iomem:
04a1f000-3f5e3fff : System RAM
  10000000-17ffffff : Crash kernel

# cat /proc/cmdline
BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.18-rc4-bobm root=/dev/sda4
raid=noautodetect crashkernel8M@256M panic=1 ro

relevant CONFIG settings (from /proc/config.gz)

CONFIG_HOTPLUG=y
CONFIG_IA64_HP_ZX1=y
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
CONFIG_HOTPLUG_CPU=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
# CONFIG_SPARSEMEM_MANUAL is not set
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_HOTPLUG_PCI is not set
CONFIG_AGP_HP_ZX1=y
CONFIG_PROC_VMCORE=y

Bob Montgomery

