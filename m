From: Frank Scheiner <frank.scheiner@web.de>
Date: Fri, 26 May 2023 10:55:14 +0000
Subject: Boot regression in Linux v6.4-rc3
Message-Id: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear all,

there is a boot regression in effect in Linux v6.4-rc3 that affects at
least:

* rx2620 (w/2 x Montecito and zx1)
* rx2800-i2 (w/1 x Tukwila)

...(see second part of [1] and following posts for more details, [2] and
[3] for the respective logs), example here:

```
ELILO v3.16 for EFI/IA-64
..
Uncompressing Linux... done
Loading file AC100221.initrd.img...done
[    0.000000] Linux version 6.4.0-rc3 (root@x4270) (ia64-linux-gcc
(GCC) 12.2.0, GNU ld (GNU Binutils) 2.39) #1 SMP Thu May 25 15:52:20
CEST 2023
[    0.000000] efi: EFI v1.1 by HP
[    0.000000] efi: SALsystab=0x3ee7a000 ACPI 2.0=0x3fe2a000
ESI=0x3ee7b000 SMBIOS=0x3ee7c000 HCDP=0x3fe28000
[    0.000000] PCDP: v3 at 0x3fe28000
[    0.000000] earlycon: uart8250 at MMIO 0x00000000f4050000 (options
'9600n8')
[    0.000000] printk: bootconsole [uart8250] enabled
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000003FE2A000 000028 (v02 HP    )
[    0.000000] ACPI: XSDT 0x000000003FE2A02C 0000CC (v01 HP     rx2620
00000000 HP   00000000)
[...]
[    3.793350] Run /init as init process
Loading, please wait...
Starting systemd-udevd version 252.6-1
[    3.951100] ------------[ cut here ]------------
[    3.951100] WARNING: CPU: 6 PID: 140 at kernel/module/main.c:1547
__layout_sections+0x370/0x3c0
[    3.949512] Unable to handle kernel paging request at virtual address
1000000000000000
[    3.951100] Modules linked in:
[    3.951100] CPU: 6 PID: 140 Comm: (udev-worker) Not tainted 6.4.0-rc3 #1
[    3.956161] (udev-worker)[142]: Oops 11003706212352 [1]
[    3.951774] Hardware name: hp server rx2620                   , BIOS
04.29
11/30/2007
[    3.951774]
[    3.951774] Call Trace:
[    3.958339] Unable to handle kernel paging request at virtual address
1000000000000000
[    3.956161] Modules linked in:
[    3.951774]  [<a0000001000156d0>] show_stack.part.0+0x30/0x60
[    3.951774]                                 sp=e000000183a67b20
bsp=e000000183a61628
[    3.956161]
[    3.956161]
```

[1]: https://lists.debian.org/debian-ia64/2023/05/msg00010.html

[2]: https://pastebin.com/SAUKbG7Z

[3]: https://pastebin.com/v1TTB2x3

With the needed modules compiled into the kernel the rx2620 (only tested
there yet) boots correctly, though for v6.4-rc2 with kernel oopses (with
similar content), for v6.4-rc3 actually w/o kernel oopses.

According to bisecting between:

GOOD: `cec24b8b6bb841a19b5c5555b600a511a8988100` and

BAD: `b6a7828502dc769e1a5329027bc5048222fa210a` (already in effect there)

...the problem was introduced with:

```
root@x4270:/usr/src/linux-on-ramdisk# git bisect bad
ac3b43283923440900b4f36ca5f9f0b1ca43b70e is the first bad commit
commit ac3b43283923440900b4f36ca5f9f0b1ca43b70e
Author: Song Liu <song@kernel.org>
Date:   Mon Feb 6 16:28:02 2023 -0800

     module: replace module_layout with module_memory

     module_layout manages different types of memory (text, data,
rodata, etc.)
     in one allocation, which is problematic for some reasons:

     1. It is hard to enable CONFIG_STRICT_MODULE_RWX.
     2. It is hard to use huge pages in modules (and not break strict rwx).
     3. Many archs uses module_layout for arch-specific data, but it is not
        obvious how these data are used (are they RO, RX, or RW?)

     Improve the scenario by replacing 2 (or 3) module_layout per module
with
     up to 7 module_memory per module:

             MOD_TEXT,
             MOD_DATA,
             MOD_RODATA,
             MOD_RO_AFTER_INIT,
             MOD_INIT_TEXT,
             MOD_INIT_DATA,
             MOD_INIT_RODATA,

     and allocating them separately. This adds slightly more entries to
     mod_tree (from up to 3 entries per module, to up to 7 entries per
     module). However, this at most adds a small constant overhead to
     __module_address(), which is expected to be fast.

     Various archs use module_layout for different data. These data are put
     into different module_memory based on their location in module_layout.
     IOW, data that used to go with text is allocated with
MOD_MEM_TYPE_TEXT;
     data that used to go with data is allocated with MOD_MEM_TYPE_DATA,
etc.

     module_memory simplifies quite some of the module code. For example,
     ARCH_WANTS_MODULES_DATA_IN_VMALLOC is a lot cleaner, as it just uses a
     different allocator for the data. kernel/module/strict_rwx.c is also
     much cleaner with module_memory.

     Signed-off-by: Song Liu <song@kernel.org>
     Cc: Luis Chamberlain <mcgrof@kernel.org>
     Cc: Thomas Gleixner <tglx@linutronix.de>
     Cc: Peter Zijlstra <peterz@infradead.org>
     Cc: Guenter Roeck <linux@roeck-us.net>
     Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
     Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
     Reviewed-by: Christophe Leroy <christophe.leroy@csgroup.eu>
     Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
     Signed-off-by: Luis Chamberlain <mcgrof@kernel.org>

  arch/arc/kernel/unwind.c        |  12 +-
  arch/arm/kernel/module-plts.c   |   9 +-
  arch/arm64/kernel/module-plts.c |  13 +-
  arch/ia64/kernel/module.c       |  24 +--
  arch/mips/kernel/vpe.c          |  11 +-
  arch/parisc/kernel/module.c     |  51 ++----
  arch/powerpc/kernel/module_32.c |   7 +-
  arch/s390/kernel/module.c       |  26 +--
  arch/x86/kernel/callthunks.c    |   4 +-
  arch/x86/kernel/module.c        |   4 +-
  include/linux/module.h          |  89 +++++++---
  kernel/module/internal.h        |  40 ++---
  kernel/module/kallsyms.c        |  58 ++++---
  kernel/module/kdb.c             |  17 +-
  kernel/module/main.c            | 375
++++++++++++++++++++--------------------
  kernel/module/procfs.c          |  16 +-
  kernel/module/strict_rwx.c      |  99 ++---------
  kernel/module/tree_lookup.c     |  39 ++---
  18 files changed, 427 insertions(+), 467 deletions(-)

root@x4270:/usr/src/linux-on-ramdisk# git bisect log
git bisect start
# status: waiting for both good and bad commits
# good: [cec24b8b6bb841a19b5c5555b600a511a8988100] Merge tag
'char-misc-6.4-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
git bisect good cec24b8b6bb841a19b5c5555b600a511a8988100
# status: waiting for bad commit, 1 good commit known
# bad: [b6a7828502dc769e1a5329027bc5048222fa210a] Merge tag
'modules-6.4-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux
git bisect bad b6a7828502dc769e1a5329027bc5048222fa210a
# bad: [3f0dedc39039a75670817a1afffa77b6cee077cb] dmaengine: remove
MODULE_LICENSE in non-modules
git bisect bad 3f0dedc39039a75670817a1afffa77b6cee077cb
# bad: [b10addf37bbcaee66672eb54c15532266c8daea6] module: add
symbol-name to pr_debug Absolute symbol
git bisect bad b10addf37bbcaee66672eb54c15532266c8daea6
# bad: [85e6f61c134f111232d27d3f63667c1bccbbc12d] module: move early
sanity checks into a helper
git bisect bad 85e6f61c134f111232d27d3f63667c1bccbbc12d
# bad: [05777499a81298ef7e4a5e32a6f744f1f937a80c] ARM: dyndbg: allow
including dyndbg.h in decompressor
git bisect bad 05777499a81298ef7e4a5e32a6f744f1f937a80c
# bad: [efaa2496bae66f0a78efa60d9b73ceef5ec63d79] module: fix MIPS
module_layout -> module_memory
git bisect bad efaa2496bae66f0a78efa60d9b73ceef5ec63d79
# bad: [9e07f161717ab8e8ac1206bf82546511e24cbb7b] module: Remove the
unused function within
git bisect bad 9e07f161717ab8e8ac1206bf82546511e24cbb7b
# bad: [ac3b43283923440900b4f36ca5f9f0b1ca43b70e] module: replace
module_layout with module_memory
git bisect bad ac3b43283923440900b4f36ca5f9f0b1ca43b70e
# first bad commit: [ac3b43283923440900b4f36ca5f9f0b1ca43b70e] module:
replace module_layout with module_memory
```

...and merged with commit `b6a7828502dc769e1a5329027bc5048222fa210a`:

```
commit b6a7828502dc769e1a5329027bc5048222fa210a
Merge: d06f5a3f7140 8660484ed1cf
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Apr 27 16:36:55 2023 -0700

     Merge tag 'modules-6.4-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux

     Pull module updates from Luis Chamberlain:
      "The summary of the changes for this pull requests is:

        - Song Liu's new struct module_memory replacement

        - Nick Alcock's MODULE_LICENSE() removal for non-modules

        - My cleanups and enhancements to reduce the areas where we vmalloc
          module memory for duplicates, and the respective debug code which
          proves the remaining vmalloc pressure comes from userspace.
[...]
```

Could someone have a look into this, please?

Cheers,
Frank

P.S.
There is also a bug for this specific commit:

```
kmemleaks on ac3b43283923 ("module: replace module_layout with
module_memory")
```

...on [4], reported on 2023-04-03, but I don't know if its content is
related to the problems on ia64.

[4]: https://bugzilla.kernel.org/show_bug.cgi?id=217296
