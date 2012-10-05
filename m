From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Fri, 05 Oct 2012 02:20:16 +0000
Subject: [PATCH 0/10] memory-hotplug: hot-remove physical memory
Message-Id: <506E43E0.70507@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

The patch-set was divided from following thread's patch-set.

https://lkml.org/lkml/2012/9/5/201

If you want to know the reason, please read following thread.

https://lkml.org/lkml/2012/10/2/83

The patch-set has only the function of kernel core side for physical
memory hot remove. So if you use the patch, please apply following
patches.

- bug fix for memory hot remove
  https://lkml.org/lkml/2012/9/27/39
  https://lkml.org/lkml/2012/10/2/83
  http://www.spinics.net/lists/linux-mm/msg42982.html
  
- acpi framework
  https://lkml.org/lkml/2012/10/3/126
  https://lkml.org/lkml/2012/10/3/641

The patches can free/remove the following things:

  - /sys/firmware/memmap/X/{end, start, type} : [PATCH 2/10]
  - mem_section and related sysfs files       : [PATCH 3-4/10]
  - memmap of sparse-vmemmap                  : [PATCH 5-7/10]
  - page table of removed memory              : [RFC PATCH 8/10]
  - node and related sysfs files              : [RFC PATCH 9-10/10]

* [PATCH 1/10] checks whether the memory can be removed or not.

If you find lack of function for physical memory hot-remove, please let me
know.

How to test this patchset?
1. apply this patchset and build the kernel. MEMORY_HOTPLUG, MEMORY_HOTREMOVE,
   ACPI_HOTPLUG_MEMORY must be selected.
2. load the module acpi_memhotplug
3. hotplug the memory device(it depends on your hardware)
   You will see the memory device under the directory /sys/bus/acpi/devices/.
   Its name is PNP0C80:XX.
4. online/offline pages provided by this memory device
   You can write online/offline to /sys/devices/system/memory/memoryX/state to
   online/offline pages provided by this memory device
5. hotremove the memory device
   You can hotremove the memory device by the hardware, or writing 1 to
   /sys/bus/acpi/devices/PNP0C80:XX/eject.

Note: if the memory provided by the memory device is used by the kernel, it
can't be offlined. It is not a bug.

Known problems:
1. memory can't be offlined when CONFIG_MEMCG is selected.
   For example: there is a memory device on node 1. The address range
   is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
   and memory11 under the directory /sys/devices/system/memory/.
   If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
   when we online pages. When we online memory8, the memory stored page cgroup
   is not provided by this memory device. But when we online memory9, the memory
   stored page cgroup may be provided by memory8. So we can't offline memory8
   now. We should offline the memory in the reversed order.
   When the memory device is hotremoved, we will auto offline memory provided
   by this memory device. But we don't know which memory is onlined first, so
   offlining memory may fail. In such case, you should offline the memory by
   hand before hotremoving the memory device.
2. hotremoving memory device may cause kernel panicked
   This bug will be fixed by Liu Jiang's patch:
   https://lkml.org/lkml/2012/7/3/1


