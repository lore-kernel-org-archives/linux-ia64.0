From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 24 Jul 2001 01:50:38 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.7)
Message-Id: <marc-linux-ia64-105590693005887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jul 2001 16:49:32 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The latest IA-64 patch is available at:
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
>in file linux-2.4.7-ia64-010723.diff*.

The new __get_user code breaks older versions of gcc for IA64.
gcc version 2.96-ia64-000717 snap 001117
scsi_ioctl.c: In function `scsi_ioctl_send_command':
scsi_ioctl.c:366: Internal compiler error in `rws_access_regno', at config/ia64/ia64.c:3671
ia64-unknown-linux-gcc: Internal compiler error: program cpp got fatal signal 13

Time to upgrade gcc.  Workaround for old versions.

Index: 7.11/drivers/scsi/scsi_ioctl.c
--- 7.11/drivers/scsi/scsi_ioctl.c Fri, 06 Jul 2001 09:49:24 +1000 kaos (linux-2.4/U/b/19_scsi_ioctl 1.2.2.3 644)
+++ 7.11(w)/drivers/scsi/scsi_ioctl.c Tue, 24 Jul 2001 11:44:19 +1000 kaos (linux-2.4/U/b/19_scsi_ioctl 1.2.2.3 644)
@@ -209,10 +209,10 @@ int scsi_ioctl_send_command(Scsi_Device 
 	if (verify_area(VERIFY_READ, sic, sizeof(Scsi_Ioctl_Command)))
 		return -EFAULT;
 
-	if(__get_user(inlen, &sic->inlen))
+	if(get_user(inlen, &sic->inlen))
 		return -EFAULT;
 		
-	if(__get_user(outlen, &sic->outlen))
+	if(get_user(outlen, &sic->outlen))
 		return -EFAULT;
 
 	/*


