From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Fri, 01 Sep 2000 21:00:36 +0000
Subject: [Linux-ia64] [PATCH] duplicate #define's in arch/ia64/kernel/minstate.h??
Message-Id: <marc-linux-ia64-105590678205442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It seems that the definition of STOPS, SAVE_MIN_WITH_COVER,
SAVE_MIN_WITH_COVER_R19 and SAVE_MIN are duplicated at the end
of arch/ia64/kernel/minstate.h.  Is this a typo, or am I missing
something?

Here's a patch (based on 2.4.0-test7) which removes the duplicates
if it's an error.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com

--- minstate.h	Thu Jun 22 10:09:44 2000
+++ /homes/orourke/minstate.h	Fri Sep  1 16:37:47 2000
@@ -192,13 +192,3 @@
 #define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs,) STOPS
 #define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs, mov 
r15=r19) STOPS
 #define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=r0,) STOPS
-
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-# define STOPS	nop.i 0x0;; nop.i 0x0;; nop.i 0x0;;
-#else
-# define STOPS
-#endif
-
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs,) STOPS
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs, mov 
r15=r19) STOPS
-#define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=r0,) STOPS




