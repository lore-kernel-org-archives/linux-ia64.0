From: Nathan Scott <nathans@sgi.com>
Date: Thu, 16 Oct 2003 22:47:57 +0000
Subject: Re: IA64 ino_t incorrectly sized?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ADZbWkCsHQ7r3kzd"
Message-Id: <marc-linux-ia64-106634472003848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
To: linux-ia64@vger.kernel.org


--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

On Wed, Oct 15, 2003 at 06:20:25PM -0700, David Mosberger wrote:
>   >>  (Neil, to give you some background: we'd like to change ino_t on
>   >> ia64 from 32 to 64 bits and found that the only potential ABI
>   >> issue is due to NFS; "struct nfsctl_export" is definitely an
>   >> issue, but perhaps we can live with that.  I'm less certain about
>   >> any issues exportfs might have.)
> 
>   Neil> ex_ino in nfsctl_export is not actually used, so all that is
>   Neil> needed is to make sure user_space and kernel_space agree on
>   Neil> the side of the field.  Maybe a __kernel_old_ino_t or
>   Neil> soemthing.  But I would be quite happy to #ifdef out that
>   Neil> system call for ia64 if that was preferred.
> 
>   Neil> So in short: there is no big problem, and the small problem is
>   Neil> largely one of aesthetics.
> 
> OK, perhaps for now you could use Nathan's #ifdef __ia64__?  Something
> along the lines of __kernel_old_ino_t certainly would be cleaner, if
> other arches need something similar.
> 

What's your preference here Neil?  I'll make a patch to create
__kernel_old_ino_t for each arch and nfsd/syscall.h if you like
that approach, else these patches seem to be all we need for ABI
compatibility now.

thanks.

-- 
Nathan

--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ino_t-2.6.patch"


===========================================================================
linux/include/asm-ia64/posix_types.h
===========================================================================

--- /usr/tmp/TmpDir.2032422-0/linux/include/asm-ia64/posix_types.h_1.4	Wed Oct 15 07:57:15 2003
+++ linux/include/asm-ia64/posix_types.h	Tue Oct 14 16:23:17 2003
@@ -10,7 +10,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-typedef unsigned int	__kernel_ino_t;
+typedef unsigned long	__kernel_ino_t;
 typedef unsigned int	__kernel_mode_t;
 typedef unsigned int	__kernel_nlink_t;
 typedef long		__kernel_off_t;

===========================================================================
linux/include/linux/nfsd/syscall.h
===========================================================================

--- /usr/tmp/TmpDir.2032422-0/linux/include/linux/nfsd/syscall.h_1.11	Wed Oct 15 07:57:15 2003
+++ linux/include/linux/nfsd/syscall.h	Tue Oct 14 16:18:07 2003
@@ -60,7 +60,11 @@
 	char			ex_client[NFSCLNT_IDMAX+1];
 	char			ex_path[NFS_MAXPATHLEN+1];
 	__kernel_old_dev_t	ex_dev;
+#ifdef __ia64__
+	unsigned int		ex_ino;	/* ABI preservation */
+#else
 	__kernel_ino_t		ex_ino;
+#endif
 	int			ex_flags;
 	__kernel_uid_t		ex_anon_uid;
 	__kernel_gid_t		ex_anon_gid;


--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ino_t-2.4.patch"


===========================================================================
linux/include/asm-ia64/posix_types.h
===========================================================================

--- /usr/tmp/TmpDir.14060-0/linux/include/asm-ia64/posix_types.h_1.1	Wed Oct 15 09:13:59 2003
+++ linux/include/asm-ia64/posix_types.h	Fri Oct 10 11:48:09 2003
@@ -11,7 +11,7 @@
  */
 
 typedef unsigned int	__kernel_dev_t;
-typedef unsigned int	__kernel_ino_t;
+typedef unsigned long	__kernel_ino_t;
 typedef unsigned int	__kernel_mode_t;
 typedef unsigned int	__kernel_nlink_t;
 typedef long		__kernel_off_t;

===========================================================================
linux/include/linux/nfsd/syscall.h
===========================================================================

--- /usr/tmp/TmpDir.14060-0/linux/include/linux/nfsd/syscall.h_1.6	Wed Oct 15 09:13:59 2003
+++ linux/include/linux/nfsd/syscall.h	Tue Oct 14 16:06:11 2003
@@ -60,7 +60,11 @@
 	char			ex_client[NFSCLNT_IDMAX+1];
 	char			ex_path[NFS_MAXPATHLEN+1];
 	__kernel_dev_t		ex_dev;
+#ifdef __ia64__
+	unsigned int		ex_ino;	/* ABI preservation */
+#else
 	__kernel_ino_t		ex_ino;
+#endif
 	int			ex_flags;
 	__kernel_uid_t		ex_anon_uid;
 	__kernel_gid_t		ex_anon_gid;
@@ -81,7 +85,11 @@
 struct nfsctl_fhparm {
 	struct sockaddr		gf_addr;
 	__kernel_dev_t		gf_dev;
+#ifdef __ia64__
+	unsigned int		gf_ino;	/* ABI preservation */
+#else
 	__kernel_ino_t		gf_ino;
+#endif
 	int			gf_version;
 };
 


--ADZbWkCsHQ7r3kzd--
