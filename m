From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 09 Jan 2001 22:46:27 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for kernel DRM build
Message-Id: <marc-linux-ia64-105590678205903@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This should be labeled a toolchain issue.  The problem occurs whenever
someone is building and linking against an "empty" archive.  The same
problem occurred in the "media/" subdirectory but I did a quick hack to
work around the problem.

	--david

>>>>> On Tue, 09 Jan 2001 14:32:23 -0800, Uros Prestor <uros@turbolinux.com> said:

  Uros> When building the latest 2.4.0-010109 kernel with DRI support
  Uros> enabled, I got the following link-time error:

  Uros>      ld: drivers/char/drm/drm.o: linking 64-bit files with
  Uros> 32-bit files ld: drivers/char/drm/drm.o: linking constant-gp
  Uros> files with non-constant-gp files

  Uros> It turns out that drm.o was built as follows:

  Uros>      rm -f drmlib.a ar rcs drmlib.a init.o memory.o proc.o
  Uros> auth.o context.o drawable.o bufs.o lists.o lock.o ioctl.o
  Uros> fops.o vm.o dma.o ctxbitmap.o rm -f drm.o ld -r -o drm.o
  Uros> drmlib.a

  Uros> Looks like the ar output confuses the linker.  I don't even
  Uros> know if this is supposed to work with the current toolchain.
  Uros> In any case, if you remove the ar step and use ld -r directly
  Uros> the problem disappears.  The enclosed patch fixes the DRI
  Uros> Makefile to remove the ar step.

  Uros> Uros.

  Uros> -- Uros Prestor uros@turbolinux.com


  Uros> diff -ruN linux-2.4.0-010109/drivers/char/drm/Makefile
  Uros> linux-2.4.0-010109.drm/drivers/char/drm/Makefile ---
  Uros> linux-2.4.0-010109/drivers/char/drm/Makefile Thu Jan 4
  Uros> 13:07:01 2001 +++
  Uros> linux-2.4.0-010109.drm/drivers/char/drm/Makefile Tue Jan 9
  Uros> 13:43:21 2001 @@ -63,9 +63,9 @@ lib-objs-mod := $(patsubst
  Uros> %.o,%-mod.o,$(lib-objs))
 
  Uros>  ifdef MAKING_MODULES - lib = drmlib-mod.a + lib   Uros> drmlib-mod.o else - obj-y += drmlib.a + obj-y += drmlib.o
  Uros> endif
 
  Uros>  include $(TOPDIR)/Rules.make @@ -73,13 +73,11 @@ $(patsubst
  Uros> %.o,%.c,$(lib-objs-mod)): @ln -sf $(subst -mod,,$@) $@
 
  Uros> -drmlib-mod.a: $(lib-objs-mod) - rm -f $@ - $(AR)
  Uros> $(EXTRA_ARFLAGS) rcs $@ $(lib-objs-mod) +drmlib-mod.o:
  Uros> $(lib-objs-mod) + $(LD) -r -o $@ $(lib-objs-mod)
 
  Uros> -drmlib.a: $(lib-objs) - rm -f $@ - $(AR) $(EXTRA_ARFLAGS) rcs
  Uros> $@ $(lib-objs) +drmlib.o: $(lib-objs) + $(LD) -r -o $@
  Uros> $(lib-objs)
 
  Uros>  gamma.o: $(gamma-objs) $(lib) $(LD) -r -o $@ $(gamma-objs)
  Uros> $(lib)

