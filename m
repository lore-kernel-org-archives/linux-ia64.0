From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 30 Aug 2002 02:12:40 +0000
Subject: Re: [Linux-ia64] [PATCH] pfm_smpl_buffer_alloc needs to free vma on error
MIME-Version: 1
Content-Type: multipart/mixed; boundary="v9Ux+11Zm5mwPlX6"
Message-Id: <marc-linux-ia64-105590701906000@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905999@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905999@msgid-missing>
To: linux-ia64@vger.kernel.org

--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 30, 2002 at 11:33:17AM +1000, Kingsley Cheung wrote:
> Hi David,
> 
> In 2.4.19, arch/ia64/kernel/perfmon.c, I noticed that 
> pfm_smpl_buffer_alloc doesn't seem to be freeing the vma structure it 
> allocates if there's an error.  Here's a trivial patch to fix it:
> 
Yes, you are right. I have generated a similar patch with the labels slightly 
renamed.  Note that the patch also fixes another problem with read_unlock()
in the same function.

Thanks for spotting this.

--
-Stephane


--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=perfmon-020829

--- linux.2419/arch/ia64/kernel/perfmon.c.old	Wed Aug 28 12:14:22 2002
+++ linux.2419/arch/ia64/kernel/perfmon.c	Thu Aug 29 19:08:02 2002
@@ -767,15 +767,14 @@
 	psb = kmalloc(sizeof(*psb), GFP_KERNEL);
 	if (psb == NULL) {
 		DBprintk(("Can't allocate sampling buffer descriptor\n"));
-		pfm_rvfree(smpl_buf, size);
-		return -ENOMEM;
+		goto error_kmalloc;
 	}
 
 	/* allocate vma */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (!vma) {
 		DBprintk(("Cannot allocate vma\n"));
-		goto error;
+		goto error_kmem;
 	}
 	/*
 	 * partially initialize the vma for the sampling buffer
@@ -875,8 +874,11 @@
 	return 0;
 
 error:
-	pfm_rvfree(smpl_buf, size);
+	kmem_cache_free(vm_area_cachep, vma);
+error_kmem:
 	kfree(psb);
+error_kmalloc:
+	pfm_rvfree(smpl_buf, size);
 	return -ENOMEM;
 }
 
@@ -1057,7 +1059,10 @@
 			/*
 			 * check if we can send this task a signal
 			 */
-			if (pfm_bad_permissions(notify_task)) goto buffer_error;
+			if (pfm_bad_permissions(notify_task)) {
+				read_unlock(&tasklist_lock);
+				goto buffer_error;
+			}
 
 			/* 
 		 	 * make visible

--v9Ux+11Zm5mwPlX6--

