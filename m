From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 30 Jul 2002 08:28:28 +0000
Subject: [Linux-ia64] Re: insmod bug causes kernel unwind failures for module text
Message-Id: <marc-linux-ia64-105590701905853@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Jul 2002 13:38:27 -0400, 
Dave Anderson <anderson@redhat.com> wrote:
>There is a bug in the initialization of the unw_table_entry structures for
>all kernel modules, such that any unwind operation that comes upon a kernel
>module text address will fail to find its associated unwind info data in
>the build_script() routine.  (Actually it won't be able to determine what
>module it belongs to.)

This patch against modutils 2.4.18 fixes it for me.  Unless I hear any
complaints in the next 24 hours, I will roll modutils 2.4.19 with this
change on July 31 11:00 UTC.

Segment base is pretty arbitrary for modules, changing it from start of
text to start of module makes it easier to convert offsets to
addresses.  It is also what hppa{64} does for SEGREL.

Index: 18.2/obj/obj_ia64.c
--- 18.2/obj/obj_ia64.c Fri, 01 Mar 2002 11:39:06 +1100 kaos (modutils-2.4/c/0_obj_ia64.c 1.5 644)
+++ 19.3(w)/obj/obj_ia64.c Tue, 30 Jul 2002 17:47:02 +1000 kaos (modutils-2.4/c/0_obj_ia64.c 1.7 644)
@@ -911,12 +911,8 @@ arch_apply_relocation(struct obj_file *f
 
     case R_IA64_SEGREL32LSB :   /* @segrel(sym + add), data4 LSB */
     case R_IA64_SEGREL64LSB :   /* @segrel(sym + add), data8 LSB */
-	if (targsec->header.sh_type & SHT_NOBITS)
-	    v = ifile->bss - v;
-	else if (targsec->header.sh_flags & SHF_EXECINSTR)
-	    v = ifile->text - v;
-	else
-	    v = ifile->data - v;
+	/* Only one segment for modules, see segment_base in arch_archdata */
+	v -= f->baseaddr;
 	if (r_info = R_IA64_SEGREL32LSB)
 	    COPY_32LSB(loc, v);
 	else
@@ -1010,7 +1006,7 @@ arch_archdata (struct obj_file *f, struc
     ad->unw_start = 0;
     ad->unw_end = 0;
     ad->unw_table = 0;
-    ad->segment_base = f->sections[1]->header.sh_addr;
+    ad->segment_base = f->baseaddr;
     for (i = 0; i < f->header.e_shnum; ++i)
     {
 	sec = f->sections[i];


