From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 13 Mar 2003 05:53:34 +0000
Subject: [Linux-ia64] Patch modutils-2.4.22 for brl in modules
Message-Id: <marc-linux-ia64-105590709806075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While testing spin_lock() using brl, I realised that modutils does not
support R_IA64_PCREL60B, so brl from a module to ia64_spinlock_contention
does not work.  This patch against modutils 2.4.22 will appear in
2.4.23, I am making it available now for people who want to test the
new spinlock code in modules.

Do not panic if kdb shows the wrong target address for brl.  ia64-dis.c
in kdb v3.0 incorrectly decodes brl, kdb v4.0 decodes it correctly.

Index: 23.9/obj/obj_ia64.c
--- 23.9/obj/obj_ia64.c Wed, 31 Jul 2002 10:41:48 +1000 kaos (modutils-2.4/c/0_obj_ia64.c 1.8 644)
+++ 23.10/obj/obj_ia64.c Thu, 13 Mar 2003 14:39:45 +1100 kaos (modutils-2.4/c/0_obj_ia64.c 1.9 644)
@@ -266,6 +266,24 @@ obj_ia64_ins_imm64(Elf64_Xword v, Elf64_
 }
 
 /*
+ * add a immediate 60 value to the instruction at slot in bundle
+ */
+enum obj_reloc
+obj_ia64_ins_pcrel60b(Elf64_Xword v, Elf64_Addr *bundle, Elf64_Xword slot)
+{
+    Elf64_Xword ins;
+
+    assert(slot = 2);
+
+    ins = obj_ia64_ins_extract_from_bundle(bundle, slot);
+    ins &= 0xffffffee00001fff;
+    ins |= ((v & 0x8000000000000000) >> 27) | ((v & 0x0000000000fffff0) << 9);
+    obj_ia64_ins_insert_in_bundle(bundle, slot, ins);
+    obj_ia64_ins_insert_in_bundle(bundle, --slot, ((v & 0x7fffffffff000000) >> 22));
+    return obj_reloc_ok;
+}
+
+/*
  * create a plt entry
  */
 enum obj_reloc
@@ -852,6 +870,10 @@ arch_apply_relocation(struct obj_file *f
 	}
 	break;
 
+    case R_IA64_PCREL60B :    /* @pcrel(sym + add), brl */
+	ret = obj_ia64_ins_pcrel60b(v - dot, bundle, slot);
+	break;
+
     case R_IA64_PCREL32LSB :    /* @pcrel(sym + add), data4 LSB */
 	COPY_32LSB(loc, v-dot);
 	break;


