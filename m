From: Bill Nottingham <notting@redhat.com>
Date: Tue, 24 Jul 2001 02:28:13 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.7)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Message-Id: <marc-linux-ia64-105590693005889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
To: linux-ia64@vger.kernel.org

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Keith Owens (kaos@melbourne.sgi.com) said: 
> The new __get_user code breaks older versions of gcc for IA64.
> gcc version 2.96-ia64-000717 snap 001117
> scsi_ioctl.c: In function `scsi_ioctl_send_command':
> scsi_ioctl.c:366: Internal compiler error in `rws_access_regno', at config/ia64/ia64.c:3671
> ia64-unknown-linux-gcc: Internal compiler error: program cpp got fatal signal 13
> 
> Time to upgrade gcc.  Workaround for old versions.

Oh, yeah, I noticed that. Here's what we used; it's similar.
It works fine in gcc3, so that's why I didn't report it earlier.

Bill

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.3-ia64-compile.patch"

--- linux/drivers/scsi/scsi_ioctl.c.foo	Tue May 29 12:59:24 2001
+++ linux/drivers/scsi/scsi_ioctl.c	Tue May 29 12:58:01 2001
@@ -200,6 +200,7 @@
 	unsigned int needed, buf_needed;
 	int timeout, retries, result;
 	int data_direction;
+	int foo;
 
 	if (!sic)
 		return -EINVAL;
@@ -209,10 +210,12 @@
 	if (verify_area(VERIFY_READ, sic, sizeof(Scsi_Ioctl_Command)))
 		return -EFAULT;
 
-	if(__get_user(inlen, &sic->inlen))
+	foo = __get_user(inlen, &sic->inlen);
+	if (foo)
 		return -EFAULT;
 		
-	if(__get_user(outlen, &sic->outlen))
+	foo = __get_user(outlen, &sic->outlen);
+	if (foo)
 		return -EFAULT;
 
 	/*

--CE+1k2dSO48ffgeK--

