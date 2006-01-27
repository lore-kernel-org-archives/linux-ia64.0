From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 27 Jan 2006 22:45:08 +0000
Subject: Re: salinfo incorrectly returning -ENOMEM
Message-Id: <43DAA274.7050901@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010701050303080603010205"
List-Id: <linux-ia64.vger.kernel.org>
References: <1138400466.19287.24.camel@krebs.dannf>
In-Reply-To: <1138400466.19287.24.camel@krebs.dannf>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010701050303080603010205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

dann frazier wrote:
> salinfo_decode will silently exit occasionally due to a failed open
> of /proc/sal/XXX/data.  This is because the kernel is returning -ENOMEM
> after attempting to vmalloc a buffer of size  
> ia64_sal_get_state_info_size(data->type).
> 
> However, on my system ia64_sal_get_state_info_size is returning 0, in
> which case I'd think a NULL vmalloc() result is correct.  
> 
> This patch assumes, of course, that 0 is a reasonable return value from
> ia64_sal_get_state_info_size().
> 

I'm working on fixing this up ...

The issue here is that ia64_sal_get_state_info_size is not doing any 
test on ia64_sal_retval.status other than to return 0.  0 is a 
reasonable return on an error, but :) as you noted the caller better be 
watching for it.

Dann, this patch will at least tell you what that return value is and 
might a) indicate a bigger bug, or b) indicate what's wrong with your 
platform ;).

(Patch is against Tony's latest tree)

P.

> 


--------------010701050303080603010205
Content-Type: text/plain;
 name="dann.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dann.patch"

diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -700,8 +700,11 @@ ia64_sal_get_state_info (u64 sal_info_ty
 	struct ia64_sal_retval isrv;
 	SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
 	              sal_info, 0, 0, 0, 0);
-	if (isrv.status)
+	if (isrv.status) {
+		printk("ia64_sal_get_state_info failed: %s\n",
+		       ia64_sal_strerror(isrv.status));
 		return 0;
+	}
 
 	return isrv.v0;
 }

--------------010701050303080603010205--
