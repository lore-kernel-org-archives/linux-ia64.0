From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Sat, 29 Sep 2001 01:45:21 +0000
Subject: Re: [Linux-ia64] Re: kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 28, 2001 at 09:13:24AM -0700, David Mosberger wrote:
> Chris do you have any updates pending?

Well, I do now :-)  On ia64 we want to map even AGP memory as
writecombined.  The appended patch should fix the rendering problems
Bill reported earlier.

Chris


--- linux-2.4.10-ia64-010924-pristine/drivers/char/drm/drm_vm.h	Wed Sep 26 09:16:03 2001
+++ linux-2.4.10-ia64-010924-dev/drivers/char/drm/drm_vm.h	Fri Sep 28 18:40:01 2001
@@ -524,8 +524,8 @@
                 	 */
                 	vma->vm_ops = &DRM(vm_ops);
 #if defined(__ia64__)
-			if (map->type != _DRM_AGP)
-				vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+			vma->vm_page_prot +			                pgprot_writecombine(vma->vm_page_prot);
 #endif
 			goto mapswitch_out;
 		}

