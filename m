From: John Levon <levon@movementarian.org>
Date: Mon, 06 Oct 2003 21:18:15 +0000
Subject: [PATCH] fix warning with CONFIG_PROFILING=y
Message-Id: <marc-linux-ia64-106547532101241@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Needs a forward declaration of struct pt_regs in Linus's current tree.

regards
john

Index: linux-ia64/include/linux/profile.h
=================================RCS file: /home/cvs/linux-2.5/include/linux/profile.h,v
retrieving revision 1.5
diff -u -a -p -r1.5 profile.h
--- linux-ia64/include/linux/profile.h	7 Mar 2003 15:39:16 -0000	1.5
+++ linux-ia64/include/linux/profile.h	6 Oct 2003 19:20:58 -0000
@@ -48,6 +48,8 @@ int profile_event_unregister(enum profil
 int register_profile_notifier(struct notifier_block * nb);
 int unregister_profile_notifier(struct notifier_block * nb);
 
+struct pt_regs;
+
 /* profiling hook activated on each timer interrupt */
 void profile_hook(struct pt_regs * regs);
 
