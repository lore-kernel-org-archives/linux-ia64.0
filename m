From: James Morris <jmorris@redhat.com>
Date: Sun, 24 Aug 2003 15:25:48 +0000
Subject: Re: selinux build failure
Message-Id: <marc-linux-ia64-106173880624656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106161286205885@msgid-missing>
In-Reply-To: <marc-linux-ia64-106161286205885@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 24 Aug 2003, Christoph Hellwig wrote:

> Argg, this is b0rked.  {asm,linux}/compat.h are for the 32bit compatiblity
> code.  64bit arches don't have fcntl64 - see the #if BITS_PER_LONG = 32
> around sys_fcntl64 in fcntl.c..

Indeed.  How about this?


- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.0-test4.orig/security/selinux/hooks.c linux-2.6.0-test4.w1/security/selinux/hooks.c
--- linux-2.6.0-test4.orig/security/selinux/hooks.c	2003-08-23 11:53:14.000000000 +1000
+++ linux-2.6.0-test4.w1/security/selinux/hooks.c	2003-08-25 01:23:11.690432168 +1000
@@ -2057,9 +2057,11 @@
 		case F_GETLK:
 		case F_SETLK:
 	        case F_SETLKW:
+#if BITS_PER_LONG = 32
 	        case F_GETLK64:
 		case F_SETLK64:
 	        case F_SETLKW64:
+#endif
 			if (!file->f_dentry || !file->f_dentry->d_inode) {
 				err = -EINVAL;
 				break;

