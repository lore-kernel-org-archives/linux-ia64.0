From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 24 Jan 2014 01:53:02 +0000
Subject: [PATCH 3/5] ia64 simserial: fix sleeping with interrupts disabled
Message-Id: <alpine.LRH.2.02.1401232045350.16873@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232043320.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232044180.16873@file01.intranet.prod.int.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.02.1401232044180.16873@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Fix sleeping with interrupts disabled warning in simserial.c:

BUG: sleeping function called from invalid context at mm/slub.c:925
in_atomic(): 0, irqs_disabled(): 1, pid: 1, name: init

Call Trace:
 [<a000000100011180>] show_stack+0x40/0x90
                                sp=E0000000070b7b40 bsp=E0000000070b12c8
 [<a000000100563e20>] dump_stack+0x20/0x40
                                sp=E0000000070b7d10 bsp=E0000000070b12b0
 [<a000000100090220>] __might_sleep+0x1e0/0x200
                                sp=E0000000070b7d10 bsp=E0000000070b1280
 [<a00000010012f060>] kmem_cache_alloc+0x70/0x430
                                sp=E0000000070b7d10 bsp=E0000000070b1230
 [<a0000001000af8c0>] request_threaded_irq+0x150/0x370
                                sp=E0000000070b7d20 bsp=E0000000070b11c0
 [<a0000001003c3b30>] activate+0x180/0x350
                                sp=E0000000070b7d20 bsp=E0000000070b1188
 [<a00000010033d2b0>] tty_port_open+0x1b0/0x280
                                sp=E0000000070b7d20 bsp=E0000000070b1140
 [<a0000001003c42b0>] rs_open+0x150/0x1a0
                                sp=E0000000070b7d20 bsp=E0000000070b1118
 [<a00000010032d930>] tty_open+0x790/0xb00
                                sp=E0000000070b7d20 bsp=E0000000070b1038
 [<a000000100144d10>] chrdev_open+0x250/0x2d0
                                sp=E0000000070b7d30 bsp=E0000000070b0ff0
 [<a000000100138b40>] do_dentry_open.isra.14+0x3d0/0x650
                                sp=E0000000070b7d40 bsp=E0000000070b0f80
 [<a00000010013a8e0>] finish_open+0x90/0xc0
                                sp=E0000000070b7d40 bsp=E0000000070b0f48
 [<a0000001001579d0>] do_last.isra.41+0x1490/0x18c0
                                sp=E0000000070b7d40 bsp=E0000000070b0e60
 [<a000000100157f60>] path_openat.isra.42+0x160/0xa00
                                sp=E0000000070b7d60 bsp=E0000000070b0d58
 [<a000000100158830>] do_filp_open+0x30/0xb0
                                sp=E0000000070b7d90 bsp=E0000000070b0d20
 [<a00000010013b190>] do_sys_open+0x200/0x330
                                sp=E0000000070b7e20 bsp=E0000000070b0cb8
 [<a00000010013b310>] sys_open+0x50/0x70
                                sp=E0000000070b7e30 bsp=E0000000070b0c60
 [<a00000010000b340>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000000070b7e30 bsp=E0000000070b0c60
 [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
                                sp=E0000000070b8000 bsp=E0000000070b0c60

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/ia64/hp/sim/simserial.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

Index: linux-2.6-ia64/arch/ia64/hp/sim/simserial.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6-ia64.orig/arch/ia64/hp/sim/simserial.=
c	2014-01-23 23:06:12.000000000 +0100
+++ linux-2.6-ia64/arch/ia64/hp/sim/simserial.c	2014-01-23 23:13:44.0000000=
00 +0100
@@ -365,7 +365,6 @@ static int activate(struct tty_port *por
 	struct serial_state *state =3D container_of(port, struct serial_state,
 			port);
 	unsigned long flags, page;
-	int retval =3D 0;
=20
 	page =3D get_zeroed_page(GFP_KERNEL);
 	if (!page)
@@ -378,13 +377,6 @@ static int activate(struct tty_port *por
 	else
 		state->xmit.buf =3D (unsigned char *) page;
=20
-	if (state->irq) {
-		retval =3D request_irq(state->irq, rs_interrupt_single, 0,
-				"simserial", state);
-		if (retval)
-			goto errout;
-	}
-
 	state->xmit.head =3D state->xmit.tail =3D 0;
=20
 	/*
@@ -398,10 +390,16 @@ static int activate(struct tty_port *por
 		tty->alt_speed =3D 230400;
 	if ((port->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_WARP)
 		tty->alt_speed =3D 460800;
-
-errout:
 	local_irq_restore(flags);
-	return retval;
+
+	if (state->irq) {
+		int retval =3D request_irq(state->irq, rs_interrupt_single, 0,
+				"simserial", state);
+		if (retval)
+			return retval;
+	}
+
+	return 0;
 }
=20
=20

