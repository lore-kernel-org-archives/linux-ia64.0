From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 09 Jan 2001 22:32:23 +0000
Subject: [Linux-ia64] [PATCH] Fix for kernel DRM build
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------F7F445E150AE4CEE9447EBC1"
Message-Id: <marc-linux-ia64-105590678205902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------F7F445E150AE4CEE9447EBC1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

When building the latest 2.4.0-010109 kernel with DRI support enabled,
I got the following link-time error:

     ld: drivers/char/drm/drm.o: linking 64-bit files with 32-bit
     files
     ld: drivers/char/drm/drm.o: linking constant-gp files with
     non-constant-gp files

It turns out that drm.o was built as follows:

     rm -f drmlib.a
     ar  rcs drmlib.a init.o memory.o proc.o auth.o context.o
     drawable.o bufs.o lists.o lock.o ioctl.o fops.o vm.o dma.o
     ctxbitmap.o
     rm -f drm.o
     ld  -r -o drm.o drmlib.a

Looks like the ar output confuses the linker.  I don't even know if this
is supposed to work with the current toolchain.  In any case, if you
remove the ar step and use ld -r directly the problem disappears.  The
enclosed patch fixes the DRI Makefile to remove the ar step.

Uros.

--
Uros Prestor
uros@turbolinux.com



--------------F7F445E150AE4CEE9447EBC1
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.4.0-ia64-drm-build.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.0-ia64-drm-build.patch"

diff -ruN linux-2.4.0-010109/drivers/char/drm/Makefile linux-2.4.0-010109.drm/drivers/char/drm/Makefile
--- linux-2.4.0-010109/drivers/char/drm/Makefile	Thu Jan  4 13:07:01 2001
+++ linux-2.4.0-010109.drm/drivers/char/drm/Makefile	Tue Jan  9 13:43:21 2001
@@ -63,9 +63,9 @@
 lib-objs-mod := $(patsubst %.o,%-mod.o,$(lib-objs))
 
 ifdef MAKING_MODULES
-  lib = drmlib-mod.a
+  lib = drmlib-mod.o
 else
-  obj-y += drmlib.a
+  obj-y += drmlib.o
 endif
 
 include $(TOPDIR)/Rules.make
@@ -73,13 +73,11 @@
 $(patsubst %.o,%.c,$(lib-objs-mod)): 
 	@ln -sf $(subst -mod,,$@) $@
 
-drmlib-mod.a: $(lib-objs-mod)
-	rm -f $@
-	$(AR) $(EXTRA_ARFLAGS) rcs $@ $(lib-objs-mod)
+drmlib-mod.o: $(lib-objs-mod)
+	$(LD) -r -o $@ $(lib-objs-mod)
 
-drmlib.a: $(lib-objs)
-	rm -f $@
-	$(AR) $(EXTRA_ARFLAGS) rcs $@ $(lib-objs)
+drmlib.o: $(lib-objs)
+	$(LD) -r -o $@ $(lib-objs)
 
 gamma.o: $(gamma-objs) $(lib)
 	$(LD) -r -o $@ $(gamma-objs) $(lib)

--------------F7F445E150AE4CEE9447EBC1--


