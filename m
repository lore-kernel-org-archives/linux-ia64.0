From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 19 May 2003 04:30:57 +0000
Subject: [Linux-ia64] offsets.h generation
MIME-Version: 1
Content-Type: multipart/mixed; boundary="j+lEU62UKj"
Message-Id: <marc-linux-ia64-105590723705941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--j+lEU62UKj
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


At present, if you change something that means offsets.h should be
regenerated, the automatic dependencies mechanism doesn't do it.

Herewith a patch that adds proper dependency generation for 
 printoffsets.s (and hence offsets.h)


--j+lEU62UKj
Content-Type: text/plain
Content-Disposition: inline;
	filename="p1"
Content-Transfer-Encoding: 7bit

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1091  -> 1.1092 
#	  arch/ia64/Makefile	1.48    -> 1.49   
#	arch/ia64/tools/Makefile	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	peterc@wombat.disy.cse.unsw.edu.au	1.1092
# [IA64] Add dependencies so that offsets.h gets regenerated if it has to be.
# --------------------------------------------
#
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Mon May 19 14:27:48 2003
+++ b/arch/ia64/Makefile	Mon May 19 14:27:48 2003
@@ -86,10 +86,12 @@
 
 prepare: include/asm-ia64/offsets.h
 
+include/asm-ia64/offsets.h : arch/ia64/tools/offsets.h
+
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
-include/asm-ia64/offsets.h:
+arch/ia64/tools/offsets.h include/asm-ia64/offsets.h:
 	$(Q)$(MAKE) $(build)=$(tools) $@
 
 define archhelp
diff -Nru a/arch/ia64/tools/Makefile b/arch/ia64/tools/Makefile
--- a/arch/ia64/tools/Makefile	Mon May 19 14:27:48 2003
+++ b/arch/ia64/tools/Makefile	Mon May 19 14:27:48 2003
@@ -32,8 +32,7 @@
 
 $(obj)/print_offsets: $(src)/print_offsets.c FORCE
 	[ -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
-	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) \
-		$(src)/print_offsets.c -o $@
+	$(CC) $(c_flags) $(src)/print_offsets.c -o $@
 
 FORCE:
 
@@ -44,7 +43,9 @@
 
 $(obj)/print_offsets.s: $(src)/print_offsets.c
 	[ -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
-	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) -S $^ -o $@
+	$(CC) $(c_flags) -MT $@ -S $^ -o $@
+	scripts/fixdep $(depfile) $@ "$(CC) $(c_flags) -MT $@ -S $^ -o $@" > $(obj)/.print_offsets.s.cmd
+	rm $(depfile)
 
 endif
 

--j+lEU62UKj--

