From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 04 Jun 2007 05:14:00 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <87hcpo47zb.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070530044448.GK86004887@sgi.com>
	<617E1C2C70743745A92448908E030B2A019298C6@scsmsx411.amr.corp.intel.com>
	<20070531005341.GF85884050@sgi.com>
In-Reply-To: <20070531005341.GF85884050@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Chinner <dgc@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org


I see many many section mismatches when compiling with gcc 4.1 and
binutils 2.17.50.20070426   They appear to be from .sdata to
.init.data.

This is with basic zx1_defconfig with a few mods.

The reason appears to be compiler weirdness..


WARNING: init/built-in.o(.sdata+0x30): Section mismatch: reference to .init.data:ino (after 'root_mountflags')

(initramfs.s contains a 32-word table `head'.  Code like:
	static __initdata struct hash {..} *head[32];

	for (p = head; p < head + 32; p++)
is generating:
  .section .sdata
L24:
	.data8 head#+256


Rather than adding 256 to head at run time, the compiler loads L24 and
uses that for the comparison.  This triggers the warning.




WARNING: arch/ia64/kernel/built-in.o(.sdata+0x110): Section mismatch: reference to .init.data:rsvd_region (between 'ia64_sal' and 'ia64_i_cache_stride_shift')
WARNING: mm/built-in.o(.sdata+0x48): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x50): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x58): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x60): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x68): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x70): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x78): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x80): Section mismatch: reference to .init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at offset -0x0)
WARNING: mm/built-in.o(.sdata+0x3c8): Section mismatch: reference to .init.data: (between 'swap_list' and 'slab_early_init')
WARNING: mm/built-in.o(.sdata+0x3d8): Section mismatch: reference to .init.data:initkmem_list3 (between 'swap_list' and 'slab_early_init')
WARNING: mm/built-in.o(.sdata+0x3e0): Section mismatch: reference to .init.data:initkmem_list3 (between 'swap_list' and 'slab_early_init')
WARNING: drivers/built-in.o(.data.rel.local+0x20a8): Section mismatch: reference to .init.text:acpi_processor_start (between 'acpi_processor_driver' and 'acpi_thermal_driver')
WARNING: drivers/built-in.o(.data.rel+0x1d80): Section mismatch: reference to .init.text:serial8250_console_setup (between 'serial8250_console' and 'dpm_active')
WARNING: drivers/built-in.o(.sdata+0x788): Section mismatch: reference to .init.data: (between 'first.20152' and 'enabled')
WARNING: drivers/built-in.o(.sdata+0x790): Section mismatch: reference to .init.data: (between 'first.20152' and 'enabled')
WARNING: drivers/built-in.o(.sdata+0xa18): Section mismatch: reference to .init.data: (between 'scsi_null_device_strs' and 'fc_dev_loss_tmo')
WARNING: drivers/built-in.o(.sdata+0xa20): Section mismatch: reference to .init.data: (between 'scsi_null_device_strs' and 'fc_dev_loss_tmo')
WARNING: drivers/built-in.o(.sdata+0xa28): Section mismatch: reference to .init.data: (between 'scsi_null_device_strs' and 'fc_dev_loss_tmo')
WARNING: drivers/built-in.o(.sdata+0xac8): Section mismatch: reference to .init.data: (between 'Symbios_trailer.24436' and 'try_direct_io')
WARNING: drivers/built-in.o(.sdata+0xb00): Section mismatch: reference to .init.data: (between 'st_max_sg_segs' and 'osst_version')
WARNING: arch/ia64/hp/common/built-in.o(.data.rel.local+0xa8): Section mismatch: reference to .init.text:acpi_sba_ioc_add (between 'acpi_sba_ioc_driver' and 'ioc_seq_ops')
WARNING: arch/ia64/hp/common/built-in.o(.sdata+0x0): Section mismatch: reference to .init.data:__setup_str_sba_page_override before 'reserve_sba_gart' (at offset -0x20000000004c2613)
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
