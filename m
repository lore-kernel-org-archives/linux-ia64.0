From: "Akiyama, Nobuyuki" <akiyama.nobuyuk@jp.fujitsu.com>
Date: Tue, 15 Jul 2008 02:46:20 +0000
Subject: [PATCH] ia64: adding parameter check to module_free()
Message-Id: <20080715114620.4381c699.akiyama.nobuyuk@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

module_free() refers the first parameter before checking.
But it is called like below(in kernel/kprobes). The first parameter is always NULL.
This happens when many probe points(>1024) are set by kprobes.
I encountered this with using SystemTap. It can set many probes easily.

static int __kprobes collect_one_slot(struct kprobe_insn_page *kip, int idx)
{
        kip->slot_used[idx] = SLOT_CLEAN;
        kip->nused--;
        if (kip->nused = 0) {
                /*
                 * Page is no longer in use.  Free it unless
                 * it's the last one.  We keep the last one
                 * so as not to have to set it up again the
                 * next time somebody inserts a probe.
                 */
                hlist_del(&kip->hlist);
                if (hlist_empty(&kprobe_insn_pages)) {
                        INIT_HLIST_NODE(&kip->hlist);
                        hlist_add_head(&kip->hlist,
                                       &kprobe_insn_pages);
                } else {
                        module_free(NULL, kip->insns); <<< 1st param always NULL
                        kfree(kip);
                }
                return 1;
        }
        return 0;
}

Thanks,
Akiyama, Nobuyuki

---
Signed-off-by: Akiyama, Nobuyuki <akiyama.nobuyuk@jp.fujitsu.com>

---
diff -Nurp linux-2.6.26.orig/arch/ia64/kernel/module.c linux-2.6.26/arch/ia64/kernel/module.c
--- linux-2.6.26.orig/arch/ia64/kernel/module.c	2008-07-16 09:51:07.000000000 +0900
+++ linux-2.6.26/arch/ia64/kernel/module.c	2008-07-16 09:51:48.000000000 +0900
@@ -321,7 +321,7 @@ module_alloc (unsigned long size)
 void
 module_free (struct module *mod, void *module_region)
 {
-	if (mod->arch.init_unw_table && module_region = mod->module_init) {
+	if (mod && mod->arch.init_unw_table && module_region = mod->module_init) {
 		unw_remove_unwind_table(mod->arch.init_unw_table);
 		mod->arch.init_unw_table = NULL;
 	}

