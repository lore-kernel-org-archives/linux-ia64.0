From: James Morris <jmorris@redhat.com>
Date: Sun, 24 Aug 2003 14:49:52 +0000
Subject: Re: selinux build failure
Message-Id: <marc-linux-ia64-106173680023378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106161286205885@msgid-missing>
In-Reply-To: <marc-linux-ia64-106161286205885@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Aug 2003, Randy.Dunlap wrote:

> selinux/hooks.c won't build on ia64.
> 2.6.0-test3 + ia64 patch or 2.6.0-test4.
> 
> security/selinux/hooks.c: In function `selinux_file_fcntl':
> security/selinux/hooks.c:2032: error: `F_GETLK64' undeclared (first use in
> this function) security/selinux/hooks.c:2033: error: `F_SETLK64' undeclared
> (first use in this function) security/selinux/hooks.c:2034: error:
> `F_SETLKW64' undeclared (first use in this function)
> 
> The __64 versions of these are defined in include/asm-ia64/compat.h. I don't
> see a good way to #include asm/compat.h, nor is it available for all
> processor architectures.

It is available via <linux/compat.h> if CONFIG_COMPAT is defined.

Does the patch below fix this for you?


- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.0-test4.orig/security/selinux/hooks.c linux-2.6.0-test4.w1/security/selinux/hooks.c
--- linux-2.6.0-test4.orig/security/selinux/hooks.c	2003-08-23 11:53:14.000000000 +1000
+++ linux-2.6.0-test4.w1/security/selinux/hooks.c	2003-08-25 00:31:58.655604472 +1000
@@ -44,6 +44,7 @@
 #include <linux/ext2_fs.h>
 #include <linux/proc_fs.h>
 #include <linux/kd.h>
+#include <linux/compat.h>
 #include <net/icmp.h>
 #include <net/ip.h>		/* for sysctl_local_port_range[] */
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */

