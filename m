From: Arun Sharma <adsharma@unix-os.sc.intel.com>
Date: Tue, 08 Jul 2003 18:57:21 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070304050409070005080703"
Message-Id: <marc-linux-ia64-105769069703392@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070304050409070005080703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Arun Sharma wrote:
> 
> Currently, sys32_fcntl64() is broken, because it passes F_*64 commands 
> to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need 
> to be converted to F_XXX before calling sys_fcntl().
> 
> We also eliminated a copy, because the 32 bit struct flock64 and the 64 
> bit struct flock seem to be identical.
> 

Turns out that the structures are not identical (even though the data types of all the members have the same size) due to alignment issues. So the copy can not be eliminated.

> This patch is relevant only to 2.4, as it has already been taken care of 
> in 2.5.

A new patch is attached.

	-Arun

--------------070304050409070005080703
Content-Type: text/plain;
 name="fcntl.29.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fcntl.29.txt"

--- linux/arch/ia64/ia32/sys_ia32.c-	Tue Jun 24 15:43:39 2003
+++ linux/arch/ia64/ia32/sys_ia32.c	Tue Jul  1 14:09:27 2003
@@ -3622,9 +3622,11 @@
 			return -EFAULT;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		ret = sys_fcntl(fd, cmd, (unsigned long) &f);
+                ret = sys_fcntl(fd, (cmd == F_GETLK64) ? F_GETLK :
+                        ((cmd == F_SETLK64) ? F_SETLK : F_SETLKW),
+                        (unsigned long) &f);
 		set_fs(old_fs);
-		if (cmd == F_GETLK && ia32_put_flock(&f, arg))
+		if (cmd == F_GETLK64 && ia32_put_flock(&f, arg))
 			return -EFAULT;
 		break;
 

--------------070304050409070005080703--

