From: Kingsley Cheung <kingsley@aurema.com>
Date: Fri, 30 Aug 2002 01:33:17 +0000
Subject: [Linux-ia64] [PATCH] pfm_smpl_buffer_alloc needs to free vma on error
Message-Id: <marc-linux-ia64-105590701905999@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

In 2.4.19, arch/ia64/kernel/perfmon.c, I noticed that 
pfm_smpl_buffer_alloc doesn't seem to be freeing the vma structure it 
allocates if there's an error.  Here's a trivial patch to fix it:

--- arch/ia64/kernel/perfmon.c  5 Jul 2002 06:17:29 -0000       1.1.7.1
+++ arch/ia64/kernel/perfmon.c  29 Aug 2002 23:29:06 -0000
@@ -647,15 +647,14 @@
        psb = kmalloc(sizeof(*psb), GFP_KERNEL);
        if (psb = NULL) {
                DBprintk(("Can't allocate sampling buffer descriptor\n"));
-               pfm_rvfree(smpl_buf, size);
-               return -ENOMEM;
+               goto kmalloc_fail;
        }
 
        /* allocate vma */
        vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
        if (!vma) {
                DBprintk(("Cannot allocate vma\n"));
-               goto error;
+               goto kmem_cache_alloc_fail;
        }
        /*
         * partially initialize the vma for the sampling buffer
@@ -750,9 +749,12 @@
 
        return 0;
 
-error:
-       pfm_rvfree(smpl_buf, size);
+ error:
+       kmem_cache_free(vm_area_cachep, vma);
+ kmem_cache_alloc_fail:
        kfree(psb);
+ kmalloc_fail:
+       pfm_rvfree(smpl_buf, size);
        return -ENOMEM;
 }


The patch compiles but it hasn't been tested.

Cheers,
	Kingsley




