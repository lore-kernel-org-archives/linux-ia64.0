From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 27 Sep 2004 23:41:19 +0000
Subject: linux-2.6.9-rc2-mm4 kernel unaligned access
Message-Id: <20040927164119.B32627@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040927163909.A32627@unix-os.sc.intel.com>
In-Reply-To: <20040927163909.A32627@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: ACPI Developer <acpi-devel@lists.sourceforge.net>
Cc: Linux IA64 <linux-ia64@vger.kernel.org>

Hi All,
	I am seeing the kernel unaligned access during linux-2.6.9-rc2-m4 boot on =

IA64 tiger platform.  But the system boots fine except I don;t see console =
login prompt,
but I can telnet. Is anyone on the mailing list seeing the same or has a fi=
x?

thanks,
Anil
--------------- console output------


ACPI: Subsystem revision 20040816
kernel unaligned access to 0xe00000003d8a195f, ip=3D0xa00000010037ac41

Call Trace:
 [<a000000100016920>] show_stack+0x80/0xa0
                                sp=E00000003c807500 bsp=E00000003c800f90
 [<a0000001000171f0>] dump_stack+0x30/0x60
                                sp=E00000003c8076d0 bsp=E00000003c800f78
 [<a000000100026ce0>] ia64_handle_unaligned+0x460/0x23c0
                                sp=E00000003c8076d0 bsp=E00000003c800ef0
 [<a00000010000dc30>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000003c807880 bsp=E00000003c800ef0
 [<a00000010000d660>] ia64_leave_kernel+0x0/0x260
                                sp=E00000003c807a90 bsp=E00000003c800ef0
 [<a00000010037ac40>] acpi_hw_low_level_write+0x2a0/0x340
                                sp=E00000003c807c60 bsp=E00000003c800e38
 [<a000000100363d50>] acpi_ev_create_gpe_block+0x530/0xea0
                                sp=E00000003c807c90 bsp=E00000003c800d98
 [<a000000100364900>] acpi_ev_gpe_initialize+0x240/0x6a0
                                sp=E00000003c807d40 bsp=E00000003c800d58
 [<a00000010035add0>] acpi_ev_initialize_events+0x190/0x260
                              sp=E00000003c807d60 bsp=E00000003c800d30
 [<a0000001003aaea0>] acpi_enable_subsystem+0x260/0x320
                                sp=E00000003c807d80 bsp=E00000003c800d08
 [<a0000001006edf20>] acpi_init+0x120/0x5a0
                                sp=E00000003c807da0 bsp=E00000003c800cc0
 [<a000000100009600>] init+0x380/0x760
                                sp=E00000003c807e30 bsp=E00000003c800c58
 [<a0000001000151c0>] kernel_thread_helper+0xe0/0x100
                                sp=E00000003c807e30 bsp=E00000003c800c30
 [<a000000100009060>] start_kernel_thread+0x20/0x40
                                sp=E00000003c807e30 bsp=E00000003c800c30
kernel unaligned access to 0xe00000003d8a196e, ip=3D0xa00000010037ac41

