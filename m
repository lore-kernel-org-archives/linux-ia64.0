From: Andreas Schwab <schwab@suse.de>
Date: Thu, 27 Mar 2003 15:02:48 +0000
Subject: [Linux-ia64] Fix error checking in sys32_ptrace
Message-Id: <marc-linux-ia64-105590723705335@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes sys32_ptrace to use ptrace_check_attach, so that it
automatically inherits all future enhancements there.

Andreas.

--- linux-2.4.19/arch/ia64/ia32/sys_ia32.c.~1~	2003-03-20 16:33:21.00000000=
0 +0100
+++ linux-2.4.19/arch/ia64/ia32/sys_ia32.c	2003-03-21 22:27:32.000000000 +0=
100
@@ -3076,26 +3076,23 @@ sys32_ptrace (int request, pid_t pid, un
 	ret =3D -ESRCH;
 	read_lock(&tasklist_lock);
 	child =3D find_task_by_pid(pid);
+	if (child)
+		get_task_struct(child);
 	read_unlock(&tasklist_lock);
 	if (!child)
 		goto out;
 	ret =3D -EPERM;
 	if (pid =3D 1)		/* no messing around with init! */
-		goto out;
+		goto out_tsk;
=20
 	if (request =3D PTRACE_ATTACH) {
 		ret =3D sys_ptrace(request, pid, addr, data, arg4, arg5, arg6, arg7, sta=
ck);
-		goto out;
-	}
-	ret =3D -ESRCH;
-	if (!(child->ptrace & PT_PTRACED))
-		goto out;
-	if (child->state !=3D TASK_STOPPED) {
-		if (request !=3D PTRACE_KILL)
-			goto out;
+		goto out_tsk;
 	}
-	if (child->p_pptr !=3D current)
-		goto out;
+
+	ret =3D ptrace_check_attach(child, request =3D PTRACE_KILL);
+	if (ret < 0)
+		goto out_tsk;
=20
 	switch (request) {
 	      case PTRACE_PEEKTEXT:
@@ -3105,12 +3102,12 @@ sys32_ptrace (int request, pid_t pid, un
 			ret =3D put_user(value, (unsigned int *) A(data));
 		else
 			ret =3D -EIO;
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_POKETEXT:
 	      case PTRACE_POKEDATA:	/* write the word at location addr */
 		ret =3D ia32_poke(regs, child, addr, data);
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_PEEKUSR:	/* read word at addr in USER area */
 		ret =3D -EIO;
@@ -3185,6 +3182,8 @@ sys32_ptrace (int request, pid_t pid, un
 		break;
=20
 	}
+  out_tsk:
+	free_task_struct(child);
   out:
 	unlock_kernel();
 	return ret;

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

