From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Aug 2003 20:43:51 +0000
Subject: Re: ia32 execve memory leak
Message-Id: <marc-linux-ia64-106193081007731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 22 August 2003 12:17 pm, Arun Sharma wrote:
> The attached patch by Tony Luck fixes a memory leak in the ia32 execve 
> code path. Please apply to both 2.4 and 2.5.

I applied this for 2.4 as follows:

#### AUTHOR arun.sharma@intel.com
#### COMMENT START
### Comments for ChangeSet
ia64: fix memory leak in sys32_execve path

The attached patch by Tony Luck fixes a memory leak in the ia32 execve 
code path. Please apply to both 2.4 and 2.5.
### Comments for arch/ia64/ia32/sys_ia32.c
(sys32_execve): Fix memory leak.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1094  -> 1.1095 
#	arch/ia64/ia32/sys_ia32.c	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/26	bjorn.helgaas@hp.com	1.1095
# fix mem leak
# --------------------------------------------
#
diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Tue Aug 26 16:10:58 2003
+++ b/arch/ia64/ia32/sys_ia32.c	Tue Aug 26 16:10:58 2003
@@ -166,9 +166,9 @@
 		current->thread.map_base  = old_map_base;
 		current->thread.task_size = old_task_size;
 		set_fs(USER_DS);	/* establish new task-size as the address-limit */
-	  out:
-		kfree(av);
 	}
+  out:
+	kfree(av);
 	return r;
 }
 

