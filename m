From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 08 Oct 2004 22:37:10 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <41671696.1060706@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060005090107080707060504"
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060005090107080707060504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 10/8/2004 1:08 AM, David Mosberger wrote:

> Unfortunately, that thread ran out in a rather unhelpful manner, as
> far as I can see.  Rusty seemed to agree that the performance-hit of
> doing it all in user-level was unacceptably high, but I didn't see any
> actual numbers.  There was a suggestion to decouple the altroot from
> the personality which makes some sense, but nobody actually did
> anything about it?
> 

I'd really like this issue to be resolved one way or the other. I'm not sure I've heard a convincing argument on why my original patch(which adds a new exec domain unconditionally) should not be applied.

I'm fine with the attached patch to set the altroot via a system call as well.

	-Arun

--------------060005090107080707060504
Content-Type: text/plain;
 name="sys-altroot.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sys-altroot.patch"

Index: linux-2.6-cvs/arch/ia64/kernel/entry.S
===================================================================
RCS file: /home/adsharma/disk2/cvs/linux-2.5/arch/ia64/kernel/entry.S,v
retrieving revision 1.49
diff -u -r1.49 entry.S
--- linux-2.6-cvs/arch/ia64/kernel/entry.S	24 Aug 2004 18:27:07 -0000	1.49
+++ linux-2.6-cvs/arch/ia64/kernel/entry.S	8 Oct 2004 17:35:53 -0000
@@ -1527,7 +1527,7 @@
 	data8 sys_mq_getsetattr
 	data8 sys_ni_syscall			// reserved for kexec_load
 	data8 sys_ni_syscall
-	data8 sys_ni_syscall			// 1270
+	data8 sys_altroot			// 1270
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
Index: linux-2.6-cvs/fs/namei.c
===================================================================
RCS file: /home/adsharma/disk2/cvs/linux-2.5/fs/namei.c,v
retrieving revision 1.110
diff -u -r1.110 namei.c
--- linux-2.6-cvs/fs/namei.c	2 Oct 2004 17:59:55 -0000	1.110
+++ linux-2.6-cvs/fs/namei.c	8 Oct 2004 18:14:11 -0000
@@ -897,7 +897,7 @@
 	return 1;
 }
 
-void set_fs_altroot(void)
+int set_fs_altroot(const char __user *altroot)
 {
 	char *emul = __emul_prefix();
 	struct nameidata nd;
@@ -905,12 +905,20 @@
 	struct dentry *dentry = NULL, *olddentry;
 	int err;
 
+	if (altroot) {
+		emul = getname(altroot);
+		if (IS_ERR(emul))
+			return PTR_ERR(emul);
+	}
+
 	if (!emul)
 		goto set_it;
 	err = path_lookup(emul, LOOKUP_FOLLOW|LOOKUP_DIRECTORY|LOOKUP_NOALT, &nd);
 	if (!err) {
 		mnt = nd.mnt;
 		dentry = nd.dentry;
+	} else {
+		return err;
 	}
 set_it:
 	write_lock(&current->fs->lock);
@@ -923,6 +931,33 @@
 		dput(olddentry);
 		mntput(oldmnt);
 	}
+	return 0;
+}
+
+asmlinkage int sys_altroot(const char __user * altroot)
+{
+	if (atomic_read(&current->fs->count) != 1) {
+		struct fs_struct *fsp, *ofsp;
+
+		fsp = copy_fs_struct(current->fs);
+		if (fsp == NULL) {
+			return -ENOMEM;
+		}
+
+		task_lock(current);
+		ofsp = current->fs;
+		current->fs = fsp;
+		task_unlock(current);
+
+		put_fs_struct(ofsp);
+	}
+
+	/*
+	 * At that point we are guaranteed to be the sole owner of
+	 * current->fs.
+	 */
+
+	return set_fs_altroot(altroot);
 }
 
 int fastcall path_lookup(const char *name, unsigned int flags, struct nameidata *nd)
Index: linux-2.6-cvs/fs/open.c
===================================================================
RCS file: /home/adsharma/disk2/cvs/linux-2.5/fs/open.c,v
retrieving revision 1.71
diff -u -r1.71 open.c
--- linux-2.6-cvs/fs/open.c	8 Aug 2004 01:54:18 -0000	1.71
+++ linux-2.6-cvs/fs/open.c	8 Oct 2004 17:38:03 -0000
@@ -584,7 +584,7 @@
 		goto dput_and_out;
 
 	set_fs_root(current->fs, nd.mnt, nd.dentry);
-	set_fs_altroot();
+	set_fs_altroot(NULL);
 	error = 0;
 dput_and_out:
 	path_release(&nd);
Index: linux-2.6-cvs/include/linux/fs_struct.h
===================================================================
RCS file: /home/adsharma/disk2/cvs/linux-2.5/include/linux/fs_struct.h,v
retrieving revision 1.7
diff -u -r1.7 fs_struct.h
--- linux-2.6-cvs/include/linux/fs_struct.h	17 Nov 2002 03:52:23 -0000	1.7
+++ linux-2.6-cvs/include/linux/fs_struct.h	8 Oct 2004 17:39:16 -0000
@@ -19,7 +19,7 @@
 }
 
 extern void exit_fs(struct task_struct *);
-extern void set_fs_altroot(void);
+extern int set_fs_altroot(const char __user *);
 extern void set_fs_root(struct fs_struct *, struct vfsmount *, struct dentry *);
 extern void set_fs_pwd(struct fs_struct *, struct vfsmount *, struct dentry *);
 extern struct fs_struct *copy_fs_struct(struct fs_struct *);
Index: linux-2.6-cvs/kernel/exec_domain.c
===================================================================
RCS file: /home/adsharma/disk2/cvs/linux-2.5/kernel/exec_domain.c,v
retrieving revision 1.18
diff -u -r1.18 exec_domain.c
--- linux-2.6-cvs/kernel/exec_domain.c	8 Sep 2004 14:50:53 -0000	1.18
+++ linux-2.6-cvs/kernel/exec_domain.c	8 Oct 2004 17:33:00 -0000
@@ -167,7 +167,7 @@
 	current->personality = personality;
 	oep = current_thread_info()->exec_domain;
 	current_thread_info()->exec_domain = ep;
-	set_fs_altroot();
+	set_fs_altroot(NULL);
 
 	module_put(oep->module);
 	return 0;

--------------060005090107080707060504--
