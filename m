From: Andreas Schwab <schwab@suse.de>
Date: Thu, 27 Mar 2003 14:07:32 +0000
Subject: [Linux-ia64] Fix request_module from ia32 process
Message-Id: <marc-linux-ia64-105590723705333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When an ia32 process triggers request_module the kernel cannot execute
modprobe because the kernel thread still has the ia32 address limits in
force.  I think a kernel thread should always have the ia64 address
limits, similar to what sys32_execve is doing.

Andreas.

--- linux-2.4.19/arch/ia64/kernel/process.c.~1~	2002-08-03 02:39:42.0000000=
00 +0200
+++ linux-2.4.19/arch/ia64/kernel/process.c	2003-03-27 11:29:02.000000000 +=
0100
@@ -476,6 +476,15 @@ kernel_thread (int (*fn)(void *), void *
=20
 	tid =3D clone(flags | CLONE_VM, 0);
 	if (parent !=3D current) {
+#ifdef CONFIG_IA32_SUPPORT
+		if (IS_IA32_PROCESS(ia64_task_regs(current))) {
+			/* A kernel thread is always a 64-bit process. */
+			current->thread.map_base  =3D DEFAULT_MAP_BASE;
+			current->thread.task_size =3D DEFAULT_TASK_SIZE;
+			ia64_set_kr(IA64_KR_IO_BASE, current->thread.old_iob);
+			ia64_set_kr(IA64_KR_TSSD, current->thread.old_k1);
+		}
+#endif
 		result =3D (*fn)(arg);
 		_exit(result);
 	}

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

