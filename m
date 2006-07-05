From: Horms <horms@verge.net.au>
Date: Wed, 05 Jul 2006 00:42:41 +0000
Subject: Re: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <20060705004239.GA23846@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 29, 2006 at 08:29:33AM +0800, Zou Nan hai wrote:
> On Thu, 2006-06-29 at 09:44, Horms wrote:
> > On Thu, Jun 29, 2006 at 06:38:22AM +0800, Zou Nan hai wrote:
> > > > 
> > >   I think there is no upper and lower limit of crash kernel base
> > >   address, but the base address should be aligned to 64M.
> > > 
> > > which is max(max possible IA64_GRANULE_SIZE, KERNEL_TR_PAGE_SIZE)
> > 
> > Ok, thanks. That should be an easy enough change. Can someone
> > confirm that it is necessary? Anecdotally, on my system the region
> > ended up at 48f0000 (~72Mb) and kdump does seem to work.
> 
>   That only works by accident.  kernel will pin mapping 64M PAGE to
>   kernel data and code at the  beginning. T hat is ALIGN(0x48f0000,
>   64M) = 0x4000000to 0x8000000, if the total kernel segment size is
>   less than 0x8000000 - 0x48f0000, you get the entire data and code
>   segment pin mapped in TLB.  However if the start address is very
>   near to 0x8000000, say 0x7FF0000, you will get most of kernel
>   segment out of TR mapping.  Also it is wrong to put TLB map of RAM
>   that does not exist together with kernel text and data.

Thanks, I played around with this some more, and it seems that 64Mb is
indeed the correct alignment, update patch is below, which has no
other changes.

-- 
Horms                                           
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

ia64, kexec: allow base of crashkernel to be auto-discovered

The crashkernel command line parameter accepts a size and base address for
the memory region that is reserved to be used as the memory space for a
crash kernel. At this time, on some architectures, notably i386 and x86_64,
the base address of the crash kernel needs to be modified at compile time
to match the base address passed to crashkernel. However, on ia64 the
crash kernel does not need to be relocated at compile time, thus
there the base address of the crashkernel region does not need to be fixed.

This patch allows the base address of crashkernel to be determined at boot
time if the base address passed on the command line is 0. Otherwise
the specified base address will be used, as is currently the case.

The advantage is that the region layout may vary from machine to machine,
and finding a place for the crashkernel is a manual process. This eliminates
that manual work, and I expect will make life slightly easier for distros.

The crashkernel region is placed inside the first "System RAM" region that
has space. It is aligned to 64Mb, which is
max(max possible IA64_GRANULE_SIZE, KERNEL_TR_PAGE_SIZE)

Signed-Off-By: Horms <horms@verge.net.au>

 arch/ia64/kernel/efi.c |   37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

62163c2efdc82f35f9c9c81a053ee9c28c22938a
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 5c657e6..724ff18 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1041,6 +1041,38 @@ efi_memmap_init(unsigned long *s, unsign
 	*e = (u64)++k;
 }
 
+#ifdef CONFIG_KEXEC
+/* If 0 is specified on the command line as the start address,
+ * then to insert crashk in the first "System RAM" resource where it fits.
+ * Otherwise, try and insert it at the specified base address */
+static void
+insert_crashk_resource(struct resource *res)
+{
+	unsigned long size = crashk_res.end;
+
+	if (crashk_res.start) {
+		insert_resource(res, &crashk_res);
+		return;
+	}
+
+	if (strcmp(res->name, "System RAM"))
+		return;
+
+	/* XXX: I'm not sure what max should be, for now it is ~0, but
+	 * there probably is a limit that is lower than that -- Horms */
+	if (!allocate_resource(res, &crashk_res, size, 0, ~0, PAGE_SIZE,
+			       NULL, NULL))
+		return;
+
+	/* Restore crashk_res */
+	crashk_res.end = size;
+	crashk_res.start = 0;
+}
+#else /* !CONFIG_KEXEC */
+static void
+insert_crashk_resource(struct resource *res) { }
+#endif /* CONFIG_KEXEC */
+
 void
 efi_initialize_iomem_resources(struct resource *code_resource,
 			       struct resource *data_resource)
@@ -1124,10 +1156,7 @@ efi_initialize_iomem_resources(struct re
 			 */
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
-#ifdef CONFIG_KEXEC
-			if (crashk_res.end > crashk_res.start)
-				insert_resource(res, &crashk_res);
-#endif
+			insert_crashk_resource(res);
 		}
 	}
 }

