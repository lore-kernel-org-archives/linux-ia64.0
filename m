From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Sep 2003 16:20:01 +0000
Subject: Re: 2.6 mca_asm.S VA to PA mappings
Message-Id: <marc-linux-ia64-106493893602252@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106490506400881@msgid-missing>
In-Reply-To: <marc-linux-ia64-106490506400881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 30 Sep 2003 08:42:10 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>The new version of the MCA TLB fixup code should handle both of
>these ... if I can just get it working ... I upgraded my test machine
>on Friday, and now it generates MCAs all the time, not just when I
>inject them :-(

If you are working on MCA on 2.4 and using kdb, apply this patch.  Some
MCA registers were not where the kernel unwind code expected them to be.


--- arch/ia64/kernel/mca.c-0	2003-10-01 02:16:55.000000000 +1000
+++ arch/ia64/kernel/mca.c	2003-10-01 02:17:02.000000000 +1000
@@ -2380,8 +2380,8 @@ ia64_log_print(int sal_info_type, prfunc
 /* This bit is tricky.  The main MCA handler (but not the MCA rendezvous
  * handler) has its own stack and bspstore, it does not use the current task
  * area.  The monarch INIT handler has its own stack but uses the current
- * bspstore.  The slave INIT handlers share a dedicated stack and bspstore,
- * single threading through it.
+ * bspstore.  The slave INIT handlers share a dedicated stack but use the
+ * current bspstore, single threading through the shared stack.
  *
  * For all of the MCA and INIT handlers, r13 points to the current task.  r12 is
  * not pointing to the current stack, except in the MCA rendezvous handler.
@@ -2467,6 +2467,13 @@ kdba_release_init_slave_stack(struct pt_
  * built but they are on the interrupt handler's stack, not on current.  Copy
  * them across to current and adjust b0, bspstore, etc. to suit.  Update
  * kdb_running_process to point to the copies.  Finally we can enter kdb.
+ *
+ * Assumption: unw_init_running() does DO_SAVE_SWITCH_STACK which calls
+ *             save_switch_stack() which does flushrs.  Therefore all registers
+ *             prior to br.call save_switch_stack have been written to backing
+ *             store.
+ *
+ * data->bspstore must contain ar.bsp at the time of MCA/INIT.
  */
 
 static void
@@ -2496,6 +2503,74 @@ kdba_mca_init_handler2(struct kdba_mca_i
 KDBA_UNWIND_HANDLER(kdba_mca_init_handler, struct kdba_mca_init_data, 0,
 	kdba_mca_init_handler2(data));
 
+/* The MCA handler does not use backing store in the process stack, it uses its
+ * own backing store, ia64_mca_bspstore.  How many registers are saved in the
+ * process stack and how many in ia64_mca_bspstore is timing dependent, RSE
+ * runs asynchronously. The unwind code requires that all registers be in the
+ * process stack, so copy any registers from ia64_mca_bspstore to the process
+ * stack.
+ *
+ * Registers from ar.bspstore through ar.bsp+sof at the time of the MCA are
+ * really in ia64_mca_bspstore, copy them back to the process stack.  The copy
+ * must be done register by register because the process stack and
+ * ia64_mca_bspstore have different alignments, which means that the saved RNAT
+ * data occurs at different places.
+ * 
+ * FIXME: The code assumes that all registers are valid and sets 0 RNaT words
+ * when copying back to the original stack.
+ */
+
+static void
+kdba_mca_bspstore_fixup(const sal_processor_static_info_t *s)
+{
+	u64 *old_bspstore, *old_bsp;
+	u64 *new_bspstore, *new_bsp;
+	u64 new_bsp_pa, ia64_mca_bspstore_pa;
+	u64 sof, slots;
+
+	asm volatile (";;flushrs;; mov %0=ar.bsp;;" : "=r"(new_bsp));
+
+        /* WAR for inconsistent V->P->V mappings in mca_asm.S for non-identity
+         * mapped kernels.  We can end up with a virtual address in ar.bspstore
+         * that is not the same as ia64_mca_bspstore but it still points to the
+         * same physical page as ia64_mca_bspstore.  Check the physical address
+         * instead of the virtual one.
+         */
+
+	new_bsp_pa = ia64_tpa((u64)new_bsp);
+	ia64_mca_bspstore_pa = ia64_tpa((u64)&ia64_mca_bspstore[0]);
+        if (new_bsp_pa < ia64_mca_bspstore_pa ||
+            new_bsp_pa >= ia64_mca_bspstore_pa + sizeof(ia64_mca_bspstore)) {
+		kdb_printf("%s: MCA is not using ia64_mca_bspstore, no fixup done [0x%p]\n",
+			__FUNCTION__, new_bsp);
+                return;
+        }
+
+        old_bspstore = (u64 *)(s->ar[18]);
+        old_bsp = (u64 *)(s->ar[17]);
+        sof = s->ar[64] & 0x7f;         /* from ar.pfs at time of MCA */
+        slots = ia64_rse_num_regs(old_bspstore, old_bsp) + sof;
+        new_bspstore = ia64_mca_bspstore;
+        new_bsp = ia64_rse_skip_regs(new_bspstore, slots);
+	
+        kdb_printf("DEBUG: %s: old_bspstore 0x%p old_bsp 0x%p sof %ld new_bspstore 0x%p new_bsp 0x%p slots %ld %ld\n",
+                __FUNCTION__, old_bspstore, old_bsp, sof, new_bspstore, new_bsp, slots, ia64_rse_num_regs(new_bspstore, new_bsp));
+
+	while (old_bspstore < old_bsp && new_bspstore < new_bsp) {
+		if (ia64_rse_is_rnat_slot(new_bspstore)) {
+			++new_bspstore;
+			continue;
+		}
+		if (ia64_rse_is_rnat_slot(old_bspstore)) {
+			*old_bspstore++ = 0;	/* assume that all registers are valid */
+			continue;
+		}
+		*old_bspstore++ = *new_bspstore++;
+	}
+	if (ia64_rse_is_rnat_slot(old_bspstore))
+		*old_bspstore++ = 0;
+}
+
 static void
 kdba_mca_init(int sal_info_type)
 {
@@ -2619,9 +2694,12 @@ kdba_mca_init(int sal_info_type)
 		}
 	}
 
+	/* Set up the data required by kdba_mca_init_handler2() */
 	data.regs = &regs;
 	data.r12 = regs.r12;
 	data.bspstore = s->ar[17];
+	if (sal_info_type = SAL_INFO_TYPE_MCA)
+		kdba_mca_bspstore_fixup(s);
 	unw_init_running(kdba_mca_init_handler, &data);
 }
 

