From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 10 Aug 2005 01:32:47 +0000
Subject: 2.6.13-rc6 doesn't build with hotplug option off
Message-Id: <200508100132.j7A1Wqg05828@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Using my favorite .config file, it happens that all the hotplug
options are off and the kernel doesn't build.

  LD      .tmp_vmlinux1
arch/ia64/kernel/built-in.o(.text+0x712): In function `acpi_unregister_ioapic':
: undefined reference to `iosapic_remove'
make: *** [.tmp_vmlinux1] Error 1

grep HOT .config
# CONFIG_HOTPLUG is not set
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_HOTPLUG_PCI is not set

