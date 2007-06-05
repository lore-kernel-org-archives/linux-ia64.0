From: Russ Anderson <rja@sgi.com>
Date: Tue, 05 Jun 2007 14:55:53 +0000
Subject: linux-ia64 build warning messages
Message-Id: <200706051455.l55Etr1N96333810@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01961AFE@scsmsx411.amr.corp.intel.com> from "Luck, Tony" at Jun 01, 2007 01:00:33 AM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luck Tony <tony.luck@intel.com>
Cc: Prarit Bhargava <prarit@redhat.com>, Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

Tony Luck wrote:
> 
> > I used the sn2_defconfig in the tree :)
> 
> So there is something odd happening.  Russ complained that he
> was still seeing several errors from the sn2_defconfig build
> too when I posted the "last fix" to Len.  But I don't see them
> when I build.

An additional data point.  I have a copy of Tony's test tree
pulled down on March 30th that builds without the warning messages.
The copy of Tony's test tree pulled down on May 22nd does have
warning messages.  I'm building both with the same compiler (etc).
I'm fairly certain a tree I pulled down in April built without 
warnings.  I've since blown away that tree.

The trees were pulled down using 
cg-clone git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git test

Building the new tree with an older compiler does not make the 
warnings go away.

Both are built with sn2_defconfig (using all the default options).
Using the 3/30 sn2_defconfig with the 5/22 tree (and visa-versa)
does not change the warnings.

------------------------------------------------------
  MODPOST vmlinux
WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'C.260.15660' (at offset 0x48)
WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'C.260.15660' (at offset 0x50)
WARNING: init/built-in.o - Section mismatch: reference to .init.data:ino from .sdata after 'C.260.15660' (at offset 0x58)
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.text:cpu_init from .text between 'start_secondary' (at offset 0x498f2) and 'smp_prepare_boot_cpu'
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.text:ia64_mca_cmc_vector_setup from .text between 'start_secondary' (at offset 0x49b02) and 'smp_prepare_boot_cpu'
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:smp_boot_data from .sdata before 'acpi_irq_model' (at offset -0x0)
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:rsvd_region from .sdata between 'ia64_sal' (at offset 0x98) and 'ia64_i_cache_stride_shift'
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:rsvd_region from .sdata between 'ia64_sal' (at offset 0xa0) and 'ia64_i_cache_stride_shift'
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:smp_boot_data from .sdata between 'cpu.25245' (at offset 0x228) and 'ap_wakeup_vector'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x58) and 'first_time.25893'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x60) and 'first_time.25893'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x78) and 'first_time.25893'
WARNING: mm/built-in.o - Section mismatch: reference to .init.text:set_up_list3s from .text between 'kmem_cache_create' (at offset 0x56f82) and 'drain_alien_cache'
WARNING: mm/built-in.o - Section mismatch: reference to .init.text:set_up_list3s from .text between 'kmem_cache_create' (at offset 0x57022) and 'drain_alien_cache'
WARNING: mm/built-in.o - Section mismatch: reference to .init.data:early_node_map from .sdata before 'min_free_kbytes' (at offset -0x0)
WARNING: mm/built-in.o - Section mismatch: reference to .init.data:early_node_map from .sdata before 'min_free_kbytes' (at offset -0x8)
WARNING: mm/built-in.o - Section mismatch: reference to .init.data:early_node_map from .sdata before 'min_free_kbytes' (at offset -0x10)
WARNING: mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hugetlb_infinity' (at offset 0x1d0) and 'slab_early_init'
WARNING: mm/built-in.o - Section mismatch: reference to .init.data:initkmem_list3 from .sdata between 'hugetlb_infinity' (at offset 0x1d8) and 'slab_early_init'
WARNING: mm/built-in.o - Section mismatch: reference to .init.data:initkmem_list3 from .sdata between 'hugetlb_infinity' (at offset 0x1e0) and 'slab_early_init'
WARNING: drivers/built-in.o - Section mismatch: reference to .init.text:sn_sal_console_setup from .data.rel between 'sal_console' (at offset 0x1c78) and 'ioc4_serial_submodule'
WARNING: drivers/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'scsi_null_device_strs' (at offset 0x8c0) and 'fc_dev_loss_tmo'
  OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
------------------------------------------------------

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
