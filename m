From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 05 Jun 2004 05:12:23 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16577.22071.810155.310868@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 May 2004 12:05:57 -0700, Christoph Lameter <clameter@sgi.com> said:

  Christoph> The Altix systems use a global clock as the time source
  Christoph> for gettimeofday and not the ITC.  In do_gettimeofday() a
  Christoph> cmpxchg instruction is used to insure that ITC based time
  Christoph> calculations never return an earlier time.  This cmpxchg
  Christoph> seems to be the reason for the scalability issues.

How does the attached look/work for you?

	--david

=== arch/ia64/kernel/time.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/time.c	Fri Jun  4 15:44:03 2004
+++ edited/arch/ia64/kernel/time.c	Fri Jun  4 21:40:44 2004
@@ -32,6 +32,7 @@
 
 extern unsigned long wall_jiffies;
 
+volatile unsigned long last_nsec_offset;
 u64 jiffies_64 = INITIAL_JIFFIES;
 
 EXPORT_SYMBOL(jiffies_64);
@@ -48,6 +49,7 @@
 static void
 itc_reset (void)
 {
+	last_nsec_offset = 0;
 }
 
 /*
@@ -57,6 +59,17 @@
 static void
 itc_update (long delta_nsec)
 {
+	if (last_nsec_offset > 0) {
+		unsigned long new, old;
+
+		do {
+			old = last_nsec_offset;
+			if (old > delta_nsec)
+				new = old - delta_nsec;
+			else
+				new = 0;
+		} while (cmpxchg(&last_nsec_offset, old, new) != old);
+	}
 }
 
 /*
@@ -83,7 +96,8 @@
 static struct time_interpolator itc_interpolator = {
 	.get_offset =	itc_get_offset,
 	.update =	itc_update,
-	.reset =	itc_reset
+	.reset =	itc_reset,
+	.is_drifty =	1
 };
 
 int
@@ -139,6 +153,10 @@
 		}
 		if (unlikely(read_seqretry(&xtime_lock, seq)))
 			continue;
+
+		if (!time_interpolator->is_drifty)
+			break;
+
 		/*
 		 * Ensure that for any pair of causally ordered gettimeofday() calls, time
 		 * never goes backwards (even when ITC on different CPUs are not perfectly
=== include/linux/timex.h 1.12 vs edited ==--- 1.12/include/linux/timex.h	Mon Oct 27 11:53:38 2003
+++ edited/include/linux/timex.h	Fri Jun  4 21:40:31 2004
@@ -325,6 +325,8 @@
 	unsigned long (*get_offset) (void);
 	void (*update) (long);
 	void (*reset) (void);
+	/* set to 1 if interpolation-value may vary (slightly) from CPU to CPU: */
+	unsigned long is_drifty : 1;
 
 	/* cache-cold stuff follows here: */
 	struct time_interpolator *next;
@@ -332,10 +334,6 @@
 	long drift;			/* drift in parts-per-million (or -1) */
 };
 
-extern volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-extern spin_lock_t last_nsec_offset_lock;
-#endif
 extern struct time_interpolator *time_interpolator;
 
 extern void register_time_interpolator(struct time_interpolator *);
@@ -347,31 +345,6 @@
 {
 	struct time_interpolator *ti = time_interpolator;
 
-	if (last_nsec_offset > 0) {
-#ifdef __HAVE_ARCH_CMPXCHG
-		unsigned long new, old;
-
-		do {
-			old = last_nsec_offset;
-			if (old > delta_nsec)
-				new = old - delta_nsec;
-			else
-				new = 0;
-		} while (cmpxchg(&last_nsec_offset, old, new) != old);
-#else
-		/*
-		 * This really hurts, because it serializes gettimeofday(), but without an
-		 * atomic single-word compare-and-exchange, there isn't all that much else
-		 * we can do.
-		 */
-		spin_lock(&last_nsec_offset_lock);
-		{
-			last_nsec_offset -= min(last_nsec_offset, delta_nsec);
-		}
-		spin_unlock(&last_nsec_offset_lock);
-#endif
-	}
-
 	if (ti)
 		(*ti->update)(delta_nsec);
 }
@@ -382,7 +355,6 @@
 {
 	struct time_interpolator *ti = time_interpolator;
 
-	last_nsec_offset = 0;
 	if (ti)
 		(*ti->reset)();
 }
@@ -394,7 +366,7 @@
 	struct time_interpolator *ti = time_interpolator;
 	if (ti)
 		return (*ti->get_offset)();
-	return last_nsec_offset;
+	return 0;
 }
 
 #else /* !CONFIG_TIME_INTERPOLATION */
=== kernel/timer.c 1.80 vs edited ==--- 1.80/kernel/timer.c	Thu May 27 16:30:37 2004
+++ edited/kernel/timer.c	Fri Jun  4 21:56:21 2004
@@ -1426,10 +1426,6 @@
 }
 
 #ifdef CONFIG_TIME_INTERPOLATION
-volatile unsigned long last_nsec_offset;
-#ifndef __HAVE_ARCH_CMPXCHG
-spinlock_t last_nsec_offset_lock = SPIN_LOCK_UNLOCKED;
-#endif
 
 struct time_interpolator *time_interpolator;
 static struct time_interpolator *time_interpolator_list;
