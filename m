From: Horms <horms@verge.net.au>
Date: Wed, 28 Jun 2006 11:00:54 +0000
Subject: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <20060628110052.GA11751@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

I would like to note that currently it will try and place the crashkernel
region inside the first "System RAM" region that has space. I am not
sure if there should be a lower or upper bond on the crashkernel base address,
but it will be trivial to add to the arguments passed to allocate_region()
if necessary.

Signed-Off-By: Horms <horms@verge.net.au>

 arch/ia64/kernel/efi.c |   37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

cd35b17e0c556befff3255651c36410d0f2b97aa
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
