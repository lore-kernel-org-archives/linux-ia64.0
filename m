From: Don Dugger <n0ano@n0ano.com>
Date: Thu, 26 Sep 2002 04:32:15 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
MIME-Version: 1
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Message-Id: <marc-linux-ia64-105590701906069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
To: linux-ia64@vger.kernel.org

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Nitin-

Attached is a kernel patch that should fix the SG_IO ioctl call for
IA32 programs.  If you could test it out and let me know how it works
that would be a big help.  I don't have a test program so I haven't
tested it myself but I think it should be correct, I just lifted
code from the sparc64 port that does the same thing.

The patch is against an ia64-020821.diff patched 2.4.19 kernel.

On Wed, Sep 25, 2002 at 05:25:35PM -0400, Sane_Purushottam@emc.com wrote:
> SG_IO. The application is sending SCSI commands to the devices.
> 
> Nitin Sane
> sane_purushottam@emc.com
> (508) 382-7319
> 
> 
> -----Original Message-----
> From: Don Dugger [mailto:n0ano@n0ano.com]
> Sent: Wednesday, September 25, 2002 5:08 PM
> To: Sane_Purushottam@emc.com
> Cc: kevin.vanmaren@unisys.com; linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] platform detection at run-time
> 
> 
> Nitin-
> 
> Can you tell me exactly which ioctl calls you're using that aren't
> working?  We have code in the kernel to deal with just this situation.
> I didn't transform EVERY ioctl in existence so let me know which ones
> you're using and I'll fix them.
> 
> On Wed, Sep 25, 2002 at 03:33:12PM -0400, Sane_Purushottam@emc.com wrote:
> > The reason, I have to detect the architecture at run time has to do with
> the
> > interface with (sg) driver. Since the driver is natively compiled for
> > 64-bit, it expects the data structure handed over to it, to be 64-bit
> wide.
> > Thus my 32-bit application cannot issue ioctl calls successfully.
> > 
> > So, in my application, based on the platform, I fill the appropriate
> > structure before ioctl call.
> > 
> > Nitin Sane
> > sane_purushottam@emc.com
> > (508) 382-7319
> > 
> > 
> > -----Original Message-----
> > From: Van Maren, Kevin [mailto:kevin.vanmaren@unisys.com]
> > Sent: Wednesday, September 25, 2002 3:28 PM
> > To: 'Sane_Purushottam@emc.com '; 'linux-ia64@linuxia64.org '
> > Subject: RE: [Linux-ia64] platform detection at run-time
> > 
> > 
> > Nitin,
> > 
> > Have you decided what you want to do about AMD's x86-64?
> > That is another 64-bit platform that will run your 32-bit binary.
> > 
> > Ideally all three platforms would be enough alike you don't
> > have to worry about it: is there a problem with Linux that is
> > causing you to perform this check?
> > 
> > Kevin
> > 
> > -----Original Message-----
> > From: Sane_Purushottam@emc.com
> > To: linux-ia64@linuxia64.org
> > Cc: Sane_Purushottam@emc.com
> > Sent: 9/25/02 2:18 PM
> > Subject: [Linux-ia64] platform detection at run-time
> > 
> > I have a linux application running on 32-bit machines. Due to some
> > third-party limitations, we cannot build this application on 64-bit
> > machines
> > natively. Thus we'll be using the '32-bit compatibility mode'.
> > 
> > For some application specific reasons, I need to be able to determine at
> > run-time whether the application is running on a 32-bit or a 64-bit
> > platform.
> > 
> > What I have found is that there's no reliable way for the application to
> > determine whether it's running on a 64-bit machine. I use info obtained
> > from
> > /proc/cpuinfo (more specifically family field) to determine the
> > platform.
> > However this is not standard. On Redhat 7.1 (lk 2.4.3-12) family value
> > is
> > set to IA-64 while on Redhat 7.2 (lk 2.4.9-34) this field is set to
> > 'Itanium'.
> > 
> > What is the preferred method to determine the platform at run time ??
> > Are
> > these values likely to change (after I change my code to handle this)
> > ????
> > 
> > Nitin Sane
> > sane_purushottam@emc.com
> > (508) 382-7319
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> -- 
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@n0ano.com

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_0925.l"

diff -Naur linux-2.4.19/arch/ia64/ia32/ia32_ioctl.c linux-2.4.19-ddd/arch/ia64/ia32/ia32_ioctl.c
--- linux-2.4.19/arch/ia64/ia32/ia32_ioctl.c	Fri Aug  2 18:39:42 2002
+++ linux-2.4.19-ddd/arch/ia64/ia32/ia32_ioctl.c	Wed Sep 25 21:27:11 2002
@@ -24,6 +24,12 @@
 #include <linux/if_ppp.h>
 #include <linux/ixjuser.h>
 #include <linux/i2o-dev.h>
+#include <scsi/scsi.h>
+/* Ugly hack. */
+#undef	__KERNEL__
+#include <scsi/scsi_ioctl.h>
+#define	__KERNEL__
+#include <scsi/sg.h>
 
 #include <asm/ia32.h>
 
@@ -56,6 +62,235 @@
 		|| put_user(d->d_reclen, &d32->d_reclen)
 		|| copy_to_user(d32->d_name, d->d_name, namelen + 1));
 }
+/*
+ *  The transform code for the SG_IO ioctl was brazenly lifted from
+ *  the Sparc64 port in the file `arch/sparc64/kernel/ioctl32.c'.
+ *  Thanks to Jakub Jelinek & Eddie C. Dost.
+ */
+typedef struct sg_io_hdr32 {
+	int interface_id;	/* [i] 'S' for SCSI generic (required) */
+	int dxfer_direction;	/* [i] data transfer direction  */
+	char  cmd_len;		/* [i] SCSI command length ( <= 16 bytes) */
+	char  mx_sb_len;		/* [i] max length to write to sbp */
+	short iovec_count;	/* [i] 0 implies no scatter gather */
+	int dxfer_len;		/* [i] byte count of data transfer */
+	int dxferp;		/* [i], [*io] points to data transfer memory
+					      or scatter gather list */
+	int cmdp;		/* [i], [*i] points to command to perform */
+	int sbp;		/* [i], [*o] points to sense_buffer memory */
+	int timeout;		/* [i] MAX_UINT->no timeout (unit: millisec) */
+	int flags;		/* [i] 0 -> default, see SG_FLAG... */
+	int pack_id;		/* [i->o] unused internally (normally) */
+	int usr_ptr;		/* [i->o] unused internally */
+	char  status;		/* [o] scsi status */
+	char  masked_status;	/* [o] shifted, masked scsi status */
+	char  msg_status;	/* [o] messaging level data (optional) */
+	char  sb_len_wr;	/* [o] byte count actually written to sbp */
+	short host_status;	/* [o] errors from host adapter */
+	short driver_status;	/* [o] errors from software driver */
+	int resid;		/* [o] dxfer_len - actual_transferred */
+	int duration;		/* [o] time taken by cmd (unit: millisec) */
+	int info;		/* [o] auxiliary information */
+} sg_io_hdr32_t;  /* 64 bytes long (on IA32) */
+
+struct iovec32 { unsigned int iov_base; int iov_len; };
+
+static int alloc_sg_iovec(sg_io_hdr_t *sgp, int uptr32)
+{
+	struct iovec32 *uiov = (struct iovec32 *) P(uptr32);
+	sg_iovec_t *kiov;
+	int i;
+
+	sgp->dxferp = kmalloc(sgp->iovec_count *
+			      sizeof(sg_iovec_t), GFP_KERNEL);
+	if (!sgp->dxferp)
+		return -ENOMEM;
+	memset(sgp->dxferp, 0,
+	       sgp->iovec_count * sizeof(sg_iovec_t));
+
+	kiov = (sg_iovec_t *) sgp->dxferp;
+	for (i = 0; i < sgp->iovec_count; i++) {
+		int iov_base32;
+		if (__get_user(iov_base32, &uiov->iov_base) ||
+		    __get_user(kiov->iov_len, &uiov->iov_len))
+			return -EFAULT;
+
+		kiov->iov_base = kmalloc(kiov->iov_len, GFP_KERNEL);
+		if (!kiov->iov_base)
+			return -ENOMEM;
+		if (copy_from_user(kiov->iov_base,
+				   (void *) P(iov_base32),
+				   kiov->iov_len))
+			return -EFAULT;
+
+		uiov++;
+		kiov++;
+	}
+
+	return 0;
+}
+
+static int copy_back_sg_iovec(sg_io_hdr_t *sgp, int uptr32)
+{
+	struct iovec32 *uiov = (struct iovec32 *) P(uptr32);
+	sg_iovec_t *kiov = (sg_iovec_t *) sgp->dxferp;
+	int i;
+
+	for (i = 0; i < sgp->iovec_count; i++) {
+		int iov_base32;
+
+		if (__get_user(iov_base32, &uiov->iov_base))
+			return -EFAULT;
+
+		if (copy_to_user((void *) P(iov_base32),
+				 kiov->iov_base,
+				 kiov->iov_len))
+			return -EFAULT;
+
+		uiov++;
+		kiov++;
+	}
+
+	return 0;
+}
+
+static void free_sg_iovec(sg_io_hdr_t *sgp)
+{
+	sg_iovec_t *kiov = (sg_iovec_t *) sgp->dxferp;
+	int i;
+
+	for (i = 0; i < sgp->iovec_count; i++) {
+		if (kiov->iov_base) {
+			kfree(kiov->iov_base);
+			kiov->iov_base = NULL;
+		}
+		kiov++;
+	}
+	kfree(sgp->dxferp);
+	sgp->dxferp = NULL;
+}
+
+static int sg_ioctl_trans(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	sg_io_hdr32_t *sg_io32;
+	sg_io_hdr_t sg_io64;
+	int dxferp32, cmdp32, sbp32;
+	mm_segment_t old_fs;
+	int err = 0;
+
+	sg_io32 = (sg_io_hdr32_t *)arg;
+	err = __get_user(sg_io64.interface_id, &sg_io32->interface_id);
+	err |= __get_user(sg_io64.dxfer_direction, &sg_io32->dxfer_direction);
+	err |= __get_user(sg_io64.cmd_len, &sg_io32->cmd_len);
+	err |= __get_user(sg_io64.mx_sb_len, &sg_io32->mx_sb_len);
+	err |= __get_user(sg_io64.iovec_count, &sg_io32->iovec_count);
+	err |= __get_user(sg_io64.dxfer_len, &sg_io32->dxfer_len);
+	err |= __get_user(sg_io64.timeout, &sg_io32->timeout);
+	err |= __get_user(sg_io64.flags, &sg_io32->flags);
+	err |= __get_user(sg_io64.pack_id, &sg_io32->pack_id);
+
+	sg_io64.dxferp = NULL;
+	sg_io64.cmdp = NULL;
+	sg_io64.sbp = NULL;
+
+	err |= __get_user(cmdp32, &sg_io32->cmdp);
+	sg_io64.cmdp = kmalloc(sg_io64.cmd_len, GFP_KERNEL);
+	if (!sg_io64.cmdp) {
+		err = -ENOMEM;
+		goto out;
+	}
+	if (copy_from_user(sg_io64.cmdp,
+			   (void *) P(cmdp32),
+			   sg_io64.cmd_len)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	err |= __get_user(sbp32, &sg_io32->sbp);
+	sg_io64.sbp = kmalloc(sg_io64.mx_sb_len, GFP_KERNEL);
+	if (!sg_io64.sbp) {
+		err = -ENOMEM;
+		goto out;
+	}
+	if (copy_from_user(sg_io64.sbp,
+			   (void *) P(sbp32),
+			   sg_io64.mx_sb_len)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	err |= __get_user(dxferp32, &sg_io32->dxferp);
+	if (sg_io64.iovec_count) {
+		int ret;
+
+		if ((ret = alloc_sg_iovec(&sg_io64, dxferp32))) {
+			err = ret;
+			goto out;
+		}
+	} else {
+		sg_io64.dxferp = kmalloc(sg_io64.dxfer_len, GFP_KERNEL);
+		if (!sg_io64.dxferp) {
+			err = -ENOMEM;
+			goto out;
+		}
+		if (copy_from_user(sg_io64.dxferp,
+				   (void *) P(dxferp32),
+				   sg_io64.dxfer_len)) {
+			err = -EFAULT;
+			goto out;
+		}
+	}
+
+	/* Unused internally, do not even bother to copy it over. */
+	sg_io64.usr_ptr = NULL;
+
+	if (err)
+		return -EFAULT;
+
+	old_fs = get_fs();
+	set_fs (KERNEL_DS);
+	err = sys_ioctl (fd, cmd, (unsigned long) &sg_io64);
+	set_fs (old_fs);
+
+	if (err < 0)
+		goto out;
+
+	err = __put_user(sg_io64.pack_id, &sg_io32->pack_id);
+	err |= __put_user(sg_io64.status, &sg_io32->status);
+	err |= __put_user(sg_io64.masked_status, &sg_io32->masked_status);
+	err |= __put_user(sg_io64.msg_status, &sg_io32->msg_status);
+	err |= __put_user(sg_io64.sb_len_wr, &sg_io32->sb_len_wr);
+	err |= __put_user(sg_io64.host_status, &sg_io32->host_status);
+	err |= __put_user(sg_io64.driver_status, &sg_io32->driver_status);
+	err |= __put_user(sg_io64.resid, &sg_io32->resid);
+	err |= __put_user(sg_io64.duration, &sg_io32->duration);
+	err |= __put_user(sg_io64.info, &sg_io32->info);
+	err |= copy_to_user((void *)P(sbp32), sg_io64.sbp, sg_io64.mx_sb_len);
+	if (sg_io64.dxferp) {
+		if (sg_io64.iovec_count)
+			err |= copy_back_sg_iovec(&sg_io64, dxferp32);
+		else
+			err |= copy_to_user((void *)P(dxferp32),
+					    sg_io64.dxferp,
+					    sg_io64.dxfer_len);
+	}
+	if (err)
+		err = -EFAULT;
+
+out:
+	if (sg_io64.cmdp)
+		kfree(sg_io64.cmdp);
+	if (sg_io64.sbp)
+		kfree(sg_io64.sbp);
+	if (sg_io64.dxferp) {
+		if (sg_io64.iovec_count) {
+			free_sg_iovec(&sg_io64);
+		} else {
+			kfree(sg_io64.dxferp);
+		}
+	}
+	return err;
+}
 
 asmlinkage long
 sys32_ioctl (unsigned int fd, unsigned int cmd, unsigned int arg)
@@ -266,6 +501,9 @@
 		break;
 	      default:
 		return sys_ioctl(fd, cmd, (unsigned long)arg);
+
+		case IOCTL_NR(SG_IO):
+			return(sg_ioctl_trans(fd, cmd, arg));
 
 	}
 	printk("%x:unimplemented IA32 ioctl system call\n", cmd);

--fUYQa+Pmc3FrFX/N--

