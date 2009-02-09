From: Alex Chiang <achiang@hp.com>
Date: Mon, 09 Feb 2009 18:16:16 +0000
Subject: [PATCH v2 1/2] Revert "[IA64] prevent ia64 from invoking irq
Message-Id: <20090209181616.GE19064@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209181338.GD19064@ldl.fc.hp.com>
In-Reply-To: <20090209181338.GD19064@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: tony.luck@intel.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

This reverts commit e7b140365b86aaf94374214c6f4e6decbee2eb0a.

Commit e7b14036 removes the targetted disabled CPU from the
cpu_online_map after calls to migrate_platform_irqs and fixup_irqs.

Paul McKenney states that the reasoning behind the patch was to
prevent irq handlers from running on CPUs marked offline because:

	RCU happily ignores CPUs that don't have their bits set in
	cpu_online_map, so if there are RCU read-side critical sections
	in the irq handlers being run, RCU will ignore them.  If the
	other CPUs were running, they might sequence through the RCU
	state machine, which could result in data structures being
	yanked out from under those irq handlers, which in turn could
	result in oopses or worse.

Unfortunately, both ia64 functions above look at cpu_online_map to find
a new CPU to migrate interrupts onto. This means we can potentially
migrate an interrupt off ourself back to... ourself. Uh oh.

This causes an oops when we finally try to process pending interrupts on
the CPU we want to disable. The oops results from calling __do_IRQ with
a NULL pt_regs:

Unable to handle kernel NULL pointer dereference (address 0000000000000040)
Call Trace:
 [<a000000100016930>] show_stack+0x50/0xa0
                                sp=E0000009c922fa00 bsp=E0000009c92214d0
 [<a0000001000171a0>] show_regs+0x820/0x860
                                sp=E0000009c922fbd0 bsp=E0000009c9221478
 [<a00000010003c700>] die+0x1a0/0x2e0
                                sp=E0000009c922fbd0 bsp=E0000009c9221438
 [<a0000001006e92f0>] ia64_do_page_fault+0x950/0xa80
                                sp=E0000009c922fbd0 bsp=E0000009c92213d8
 [<a00000010000c7a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=E0000009c922fc60 bsp=E0000009c92213d8
 [<a0000001000ecdb0>] profile_tick+0xd0/0x1c0
                                sp=E0000009c922fe30 bsp=E0000009c9221398
 [<a00000010003bb90>] timer_interrupt+0x170/0x3e0
                                sp=E0000009c922fe30 bsp=E0000009c9221330
 [<a00000010013a800>] handle_IRQ_event+0x80/0x120
                                sp=E0000009c922fe30 bsp=E0000009c92212f8
 [<a00000010013aa00>] __do_IRQ+0x160/0x4a0
                                sp=E0000009c922fe30 bsp=E0000009c9221290
 [<a000000100012290>] ia64_process_pending_intr+0x2b0/0x360
                                sp=E0000009c922fe30 bsp=E0000009c9221208
 [<a0000001000112d0>] fixup_irqs+0xf0/0x2a0
                                sp=E0000009c922fe30 bsp=E0000009c92211a8
 [<a00000010005bd80>] __cpu_disable+0x140/0x240
                                sp=E0000009c922fe30 bsp=E0000009c9221168
 [<a0000001006c5870>] take_cpu_down+0x50/0xa0
                                sp=E0000009c922fe30 bsp=E0000009c9221148
 [<a000000100122610>] stop_cpu+0xd0/0x200
                                sp=E0000009c922fe30 bsp=E0000009c92210f0
 [<a0000001000e0440>] kthread+0xc0/0x140
                                sp=E0000009c922fe30 bsp=E0000009c92210c8
 [<a000000100014ab0>] kernel_thread_helper+0xd0/0x100
                                sp=E0000009c922fe30 bsp=E0000009c92210a0
 [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
                                sp=E0000009c922fe30 bsp=E0000009c92210a0

I don't like this revert because it is fragile. ia64 is getting lucky
because we seem to only ever process timer interrupts in this path, but
if we ever race with an IPI here, we definitely use RCU and have the
potential of hitting an oops that Paul describes above.

Patching ia64's timer_interrupt() to check for NULL pt_regs is
insufficient though, as we still hit the above oops.

As a short term solution, I do think that this revert is the right
answer. The revert hold up under repeated testing (24+ hour test runs)
with this setup:

	- 8-way rx6600
	- randomly toggling CPU online/offline state every 2 seconds
	- running CPU exercisers, memory hog, disk exercisers, and
	  network stressors
	- average system load around ~160

In the long term, we really need to figure out why we set pt_regs =3D NULL
in ia64_process_pending_intr(). If it turns out that it is unnecessary
to do so, then we could safely re-introduce e7b14036 (along with some
other logic to be smarter about migrating interrupts).

One final note: x86 also removes the disabled CPU from cpu_online_map
and then re-enables interrupts for 1ms, presumably to handle any pending
interrupts:

arch/x86/kernel/irq_32.c (and irq_64.c):
cpu_disable_common:
	[remove cpu from cpu_online_map]

	fixup_irqs():
		for_each_irq:
			[break CPU affinities]

		local_irq_enable();
		mdelay(1);
		local_irq_disable();

So they are doing implicitly what ia64 is doing explicitly.

Cc: stable@kernel.org
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/smpboot.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 1146399..2ec5bbf 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -736,14 +736,16 @@ int __cpu_disable(void)
 			return -EBUSY;
 	}
=20
+	cpu_clear(cpu, cpu_online_map);
+
 	if (migrate_platform_irqs(cpu)) {
 		cpu_set(cpu, cpu_online_map);
 		return (-EBUSY);
 	}
=20
 	remove_siblinginfo(cpu);
-	fixup_irqs();
 	cpu_clear(cpu, cpu_online_map);
+	fixup_irqs();
 	local_flush_tlb_all();
 	cpu_clear(cpu, cpu_callin_map);
 	return 0;
--=20
1.6.0.1.161.g7f314

