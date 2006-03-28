From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 28 Mar 2006 23:48:15 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603281537500.15037@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603281853.k2SIrGg28290@unix-os.sc.intel.com> <4429ADBC.50507@free.fr>
In-Reply-To: <4429ADBC.50507@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@free.fr>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 28 Mar 2006, Zoltan Menyhart wrote:

> Why not to use separate bit operations for different purposes?
> 
> - e.g. "test_and_set_bit_N_acquire()" for lock acquisition
> - "test_and_set_bit()", "clear_bit()" as they are today
> - "release_N_clear_bit()"...
> 

That would force IA64 specifics onto all other architectures.

Could we simply define these smb_mb__*_clear_bit to be noops
and then make the atomic bit ops to have full barriers? That would satisfy 
Nick's objections.

Index: linux-2.6.16/include/asm-ia64/bitops.h
=================================--- linux-2.6.16.orig/include/asm-ia64/bitops.h	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/include/asm-ia64/bitops.h	2006-03-28 15:45:08.000000000 -0800
@@ -45,6 +45,7 @@
 		old = *m;
 		new = old | bit;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smb_mb();
 }
 
 /**
@@ -65,7 +66,7 @@
 /*
  * clear_bit() has "acquire" semantics.
  */
-#define smp_mb__before_clear_bit()	smp_mb()
+#define smp_mb__before_clear_bit()	do { } while (0)
 #define smp_mb__after_clear_bit()	do { /* skip */; } while (0)
 
 /**
@@ -92,6 +93,7 @@
 		old = *m;
 		new = old & mask;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smp_mb();
 }
 
 /**
@@ -128,6 +130,7 @@
 		old = *m;
 		new = old ^ bit;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smp_mb();
 }
 
 /**
@@ -167,6 +170,7 @@
 		old = *m;
 		new = old | bit;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smp_mb();
 	return (old & bit) != 0;
 }
 
@@ -212,6 +216,7 @@
 		old = *m;
 		new = old & mask;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smp_mb();
 	return (old & ~mask) != 0;
 }
 
@@ -257,6 +262,7 @@
 		old = *m;
 		new = old ^ bit;
 	} while (cmpxchg_acq(m, old, new) != old);
+	smp_mb();
 	return (old & bit) != 0;
 }
 
