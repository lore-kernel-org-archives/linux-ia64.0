From: Nathan Scott <nathans@sgi.com>
Date: Wed, 15 Oct 2003 01:25:04 +0000
Subject: Re: IA64 ino_t incorrectly sized?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Message-Id: <marc-linux-ia64-106618135310114@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
To: linux-ia64@vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hi David,

[ Below are updated patches.  I've added Christoph and Andrew
onto the discussion because the patches add __ia64__ ifdef's
into core kernel headers, and they've shown me cleaner ways
to do this sort of thing in the past. ]

On Wed, Oct 08, 2003 at 06:57:13PM -0700, David Mosberger wrote:
> >>>>> On Thu, 9 Oct 2003 11:25:58 +1000, Nathan Scott <nathans@sgi.com> s=
aid:
>   Nathan> e.g. the ia64 include/asm-ia64/stat.h uses long for the
>   Nathan> inode number field, and the struct inode i_ino is a long
>   Nathan> also.  So, for the most part everything works as is - there
>   Nathan> are corner cases (i.e. getdents) that this fixes though, as
>   Nathan> I explained.  It does not change any external interfaces (if
>   Nathan> it did they'd be broken already, but I haven't seen any
>   Nathan> evidence of that in my testing).
>=20
> Are you saying that you reviewed the entire syscall interface and did
> a reasonable review of anything else (e.g., /proc) that might expose
> ino_t in one way or another?

So, my brave assertion that no code would be exporting a type
called "__kernel_ino_t" turns out to be incorrect (/me hangs
head in shame) as there are two cases I see where this type
is exported to userspace.

Here's some more details about what I've reviewed and found.
If I've overlooked any areas let me know.

system call interface -- I examined the 2.4 IA64 system call
table and each of the structures passed across it in detail.
This revealed that the ustat and NFS system calls pass around
binary structures with __kernel_ino_t fields (see my updated
patches).  I then diff'd the 2.4 and 2.6 asm-ia64/unistd.h
and reviewed each of the new syscalls - there are no new 2.6
interfaces that deal with an ino_t.

procfs interfaces -- the one procfs interface I found dealing
with inode numbers is the /proc/PID/maps file.  In 2.4, this is
done in fs/proc/array.c::proc_pid_maps_get_line and in 2.6 its
done in fs/proc/task_mmu.c::show_map.  In both places, the ino
is copied out of (struct inode)->i_ino into a local unsigned
long and then formatted via "%lu".  Hence, ino_t doesn't come
into the picture here and we are not exposed to __kernel_ino_t
changes in either kernel.

ioctl interfaces -- there are several places in arch/ia64/ia32/
ia32_ioctl.c and sys_ia32.c where we copy an ino_t into an
unsigned int...
	sys_ia32.c::filldir32
	sys_ia32.c::fillonedir32
	ia32_ioctl.c::put_dirent32

These would change from copying 'unsigned int'->'unsigned int'
into 'unsigned long'->'unsigned int'.  It turns out that this
is already being done in other places, so I think its OK; e.g.
sys_ia32.c::putstat copies a kbuf->st_ino (unsigned long, from
the IA64 version of struct stat) into an ubuf->st_ino (uint).

=46rom reviewing the code with Keith Owens, it looks like this
copies the first 4 bytes (sizeof the specified field in the
user buffer) and we've "got lucky" here due to our endianness
(otherwise we would get all zeroes).  Not sure if this was
by luck or by design, but obviously it works as is.


Anyway, here's the two patches (2.6 & 2.4).  The 2.4 version
no longer applies cleanly to 2.6 due to other kernel changes,
and the 2.6 kernel deprecates one of the 2.4 NFS structures.

I'd appreciate any suggestions about a cleaner way to do the
common types.h and nfsd/syscall.h header changes.

cheers.

--=20
Nathan

--zhXaljGHf11kAtnf
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

===========================================================================
linux/include/linux/types.h
===========================================================================

--- /usr/tmp/TmpDir.2032422-0/linux/include/linux/types.h_1.14	Wed Oct 15 07:57:15 2003
+++ linux/include/linux/types.h	Tue Oct 14 16:09:06 2003
@@ -150,7 +150,11 @@
 
 struct ustat {
 	__kernel_daddr_t	f_tfree;
+#ifdef __ia64__
+	unsigned int		f_tinode;	/* ABI preservation */
+#else
 	__kernel_ino_t		f_tinode;
+#endif
 	char			f_fname[6];
 	char			f_fpack[6];
 };

--zhXaljGHf11kAtnf
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
 

===========================================================================
linux/include/linux/types.h
===========================================================================

--- /usr/tmp/TmpDir.14060-0/linux/include/linux/types.h_1.9	Wed Oct 15 09:13:59 2003
+++ linux/include/linux/types.h	Tue Oct 14 16:05:36 2003
@@ -129,7 +129,11 @@
 
 struct ustat {
 	__kernel_daddr_t	f_tfree;
+#ifdef __ia64__
+	unsigned int		f_tinode;	/* ABI preservation */
+#else
 	__kernel_ino_t		f_tinode;
+#endif
 	char			f_fname[6];
 	char			f_fpack[6];
 };

--zhXaljGHf11kAtnf--
