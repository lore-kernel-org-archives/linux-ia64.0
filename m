From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Fri, 26 Oct 2001 17:17:15 +0000
Subject: [Linux-ia64] [PATCH] Fix for the X->text->X console crash
Message-Id: <marc-linux-ia64-105590698805401@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A patch which should fix the famous X->text->X console switch crashes is
appended.  It seems that the kernel was sending a 'console reacquired'
signal to X _before_ doing a screen blank operation.  This allowed X to
be configuring the video card from one processor while the kernel
cleared parts of the VGA range from another.  Interleaving these types
of accesses apparently caused the system crashes (at least that's what
the hardware guys with PCI bus analyzers saw and the problem goes away
when running UP :-)

I posted this patch to linux-kernel last night because it doesn't seem
to be an ia64 specific problem.  Andrea Arcangeli said he thought the
patch looked alright, so that gives me some more confidence in its
correctness.  I hope Linus and Alan will be applying this soon, but in
the meantime it should fix the problem when applied to your local
kernels.  The patch is against 2.4.13-ia64-011024.

Chris


--- linux-2.4.13-ia64-011024-pristine/drivers/char/vt.c	Mon Sep 17 22:52:35 2001
+++ linux-2.4.13-ia64-011024-dev/drivers/char/vt.c	Thu Oct 25 20:46:08 2001
@@ -1184,6 +1184,24 @@
 	switch_screen(new_console);
 
 	/*
+	 * This can't appear below a successful kill_proc().  If it did,
+	 * then the *blank_screen operation could occur while X, having
+	 * received acqsig, is waking up on another processor.  This
+	 * condition can lead to overlapping accesses to the VGA range
+	 * and the framebuffer (causing system lockups).
+	 *
+	 * To account for this we duplicate this code below only if the
+	 * controlling process is gone and we've called reset_vc.
+	 */
+	if (old_vc_mode != vt_cons[new_console]->vc_mode)
+	{
+		if (vt_cons[new_console]->vc_mode = KD_TEXT)
+			unblank_screen();
+		else
+			do_blank_screen(1);
+	}
+
+	/*
 	 * If this new console is under process control, send it a signal
 	 * telling it that it has acquired. Also check if it has died and
 	 * clean up (similar to logic employed in change_console())
@@ -1209,19 +1227,15 @@
 		 * to account for and tracking tty count may be undesirable.
 		 */
 		        reset_vc(new_console);
-		}
-	}
 
-	/*
-	 * We do this here because the controlling process above may have
-	 * gone, and so there is now a new vc_mode
-	 */
-	if (old_vc_mode != vt_cons[new_console]->vc_mode)
-	{
-		if (vt_cons[new_console]->vc_mode = KD_TEXT)
-			unblank_screen();
-		else
-			do_blank_screen(1);
+			if (old_vc_mode != vt_cons[new_console]->vc_mode)
+			{
+				if (vt_cons[new_console]->vc_mode = KD_TEXT)
+					unblank_screen();
+				else
+					do_blank_screen(1);
+			}
+		}
 	}
 
 	/*

