From: Don Dugger <n0ano@valinux.com>
Date: Tue, 14 Aug 2001 16:23:47 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.8)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Message-Id: <marc-linux-ia64-105590698805075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
To: linux-ia64@vger.kernel.org

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii

David-

I discovered a minor typo, you must be using GCC 3.0.

On Tue, Aug 14, 2001 at 01:19:43AM -0700, David Mosberger wrote:
> The latest IA-64 patch is available at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
> 
> in file linux-2.4.8-ia64-010814.diff*.
> 
> One major improvement in this patch is that the machine check support
> (MCA code) should work again and better.  Thanks to Asit & crew.  Note
> that Linus switched to the DRM code needed for XFree86-4.1.  But since
> we don't 460gx have AGP support for this version yet and since most
> folks are presumably still running 4.0.x, I kept the old DRM code
> instead.  I assume this will stay so until someone (Chris?) has had a
> chance up update the 460gx code to 4.1.
> 
> Oh, I dropped support for B0-B2 CPUs.  So now, only B3 or newer CPUs
> are supported.
> 
> Enjoy,
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="scsi.patch"

--- kernel-bigsur-2.4.8-ref/drivers/scsi/scsi_ioctl.c	Tue Aug 14 10:19:50 2001
+++ kernel-bigsur/drivers/scsi/scsi_ioctl.c	Tue Aug 14 10:18:19 2001
@@ -213,7 +213,7 @@
 		return -EFAULT;
 
 #if __GNUC__ < 3
-        foo = __get_user(inlen, &sic->inlen)
+        foo = __get_user(inlen, &sic->inlen);
 	if(foo)
 		return -EFAULT;
 		

--fdj2RfSjLxBAspz7--

