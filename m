From: Matthew Wilcox <willy@debian.org>
Date: Mon, 25 Aug 2003 18:42:09 +0000
Subject: [PATCH] ia64/lib/Makefile: use call-if-changed
Message-Id: <marc-linux-ia64-106183721811204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Sam, how does this look?

 - IGNORE_FLAGS_OBJS is no longer honoured (this is the only reference to
   it in the tree).
 - Change the .o.S rule to look the same as the one in
   scripts/Makefile.build.  This means we'll generate .cmd files instead
   of the .d files which makes CVS happier.

Index: arch/ia64/lib/Makefile
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/lib/Makefile,v
retrieving revision 1.1
diff -u -p -r1.1 Makefile
--- arch/ia64/lib/Makefile	29 Jul 2003 17:00:28 -0000	1.1
+++ arch/ia64/lib/Makefile	25 Aug 2003 16:56:27 -0000
@@ -14,9 +14,6 @@ lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.
 lib-$(CONFIG_PERFMON)	+= carta_random.o
 lib-$(CONFIG_MD_RAID5)	+= xor.o
 
-IGNORE_FLAGS_OBJS =	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
-			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
-
 AFLAGS___divdi3.o	 AFLAGS___udivdi3.o	= -DUNSIGNED
 AFLAGS___moddi3.o	= 	     -DMODULO
@@ -27,26 +24,26 @@ AFLAGS___udivsi3.o	= -DUNSIGNED
 AFLAGS___modsi3.o	=	     -DMODULO
 AFLAGS___umodsi3.o	= -DUNSIGNED -DMODULO
 
-$(obj)/__divdi3.o: $(src)/idiv64.S
-	$(cmd_as_o_S)
+$(obj)/__divdi3.o: $(src)/idiv64.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__udivdi3.o: $(src)/idiv64.S
-	$(cmd_as_o_S)
+$(obj)/__udivdi3.o: $(src)/idiv64.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__moddi3.o: $(src)/idiv64.S
-	$(cmd_as_o_S)
+$(obj)/__moddi3.o: $(src)/idiv64.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__umoddi3.o: $(src)/idiv64.S
-	$(cmd_as_o_S)
+$(obj)/__umoddi3.o: $(src)/idiv64.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__divsi3.o: $(src)/idiv32.S
-	$(cmd_as_o_S)
+$(obj)/__divsi3.o: $(src)/idiv32.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__udivsi3.o: $(src)/idiv32.S
-	$(cmd_as_o_S)
+$(obj)/__udivsi3.o: $(src)/idiv32.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__modsi3.o: $(src)/idiv32.S
-	$(cmd_as_o_S)
+$(obj)/__modsi3.o: $(src)/idiv32.S FORCE
+	$(call if_changed_dep,as_o_S)
 
-$(obj)/__umodsi3.o: $(src)/idiv32.S
-	$(cmd_as_o_S)
+$(obj)/__umodsi3.o: $(src)/idiv32.S FORCE
+	$(call if_changed_dep,as_o_S)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
