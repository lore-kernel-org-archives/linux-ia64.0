From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 08 Jul 2003 21:51:16 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070606080507060506090001"
Message-Id: <marc-linux-ia64-105770113015093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070606080507060506090001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Matthew Wilcox wrote:
> On Tue, Jul 08, 2003 at 11:57:21AM -0700, Arun Sharma wrote:
> 
>>--- linux/arch/ia64/ia32/sys_ia32.c-	Tue Jun 24 15:43:39 2003
>>+++ linux/arch/ia64/ia32/sys_ia32.c	Tue Jul  1 14:09:27 2003
>>@@ -3622,9 +3622,11 @@
>> 			return -EFAULT;
>> 		old_fs = get_fs();
>> 		set_fs(KERNEL_DS);
>>-		ret = sys_fcntl(fd, cmd, (unsigned long) &f);
>>+                ret = sys_fcntl(fd, (cmd == F_GETLK64) ? F_GETLK :
> 
> 
> looks like you're using spaces instead of tabs.  tsk.
> 

I admit to cutting and pasting from 2.5 :) An updated patch with tabs is attached.

	-Arun

--------------070606080507060506090001
Content-Type: text/plain;
 name="fcntl.29.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fcntl.29.txt"

--- linux/arch/ia64/ia32/sys_ia32.c-	Tue Jun 24 15:43:39 2003
+++ linux/arch/ia64/ia32/sys_ia32.c	Tue Jul  8 14:46:57 2003
@@ -3622,9 +3622,11 @@
 			return -EFAULT;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		ret = sys_fcntl(fd, cmd, (unsigned long) &f);
+		ret = sys_fcntl(fd, (cmd == F_GETLK64) ? F_GETLK :
+			((cmd == F_SETLK64) ? F_SETLK : F_SETLKW),
+			(unsigned long) &f);
 		set_fs(old_fs);
-		if (cmd == F_GETLK && ia32_put_flock(&f, arg))
+		if (cmd == F_GETLK64 && ia32_put_flock(&f, arg))
 			return -EFAULT;
 		break;
 

--------------070606080507060506090001--

