From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 11 Jan 2001 22:02:16 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot alignment bug
Message-Id: <marc-linux-ia64-105590693005030@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005029@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005029@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 11, 2001 at 01:26:01PM -0800, H . J . Lu wrote:
> I got a kernel unaligned access bug:
> 
> The problem is
> 
>   struct bar x = { b->f4, 0, {0, 0} };
> 
> gcc uses
> 
> st8 [rX] = r0
> 
> for {0, 0}. But st8 requires 8 byte aligment while
> 
>   unsigned int f6 [2];
> 
> has 4 byte aligment.
> 
> BTW, nfs3_proc_create in fs/nfs/nfs3proc.c got miscompiled.
> 

Here is a workaround for the compiler bug.


---
--- linux/fs/nfs/nfs3proc.c.align	Thu Jan 11 13:27:25 2001
+++ linux/fs/nfs/nfs3proc.c	Thu Jan 11 13:40:59 2001
@@ -190,11 +190,17 @@ nfs3_proc_create(struct inode *dir, stru
 		 int flags, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs_fattr	dir_attr;
-	struct nfs3_createargs	arg = { NFS_FH(dir), name->name, name->len,
-					sattr, 0, { 0, 0 } };
+	struct nfs3_createargs	arg;
 	struct nfs3_diropres	res = { &dir_attr, fhandle, fattr };
 	int			status;
 
+	arg.fh = NFS_FH(dir);
+	arg.name = name->name;
+	arg.len = name->len,
+	arg.sattr = sattr;
+	arg.createmode = 0;
+	arg.verifier [0] = 0;
+	arg.verifier [1] = 0;
 	dprintk("NFS call  create %s\n", name->name);
 	arg.createmode = NFS3_CREATE_UNCHECKED;
 	if (flags & O_EXCL) {
@@ -362,10 +368,17 @@ nfs3_proc_mkdir(struct inode *dir, struc
 		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs_fattr	dir_attr;
-	struct nfs3_createargs	arg = { NFS_FH(dir), name->name, name->len,
-					sattr, 0, { 0, 0 } };
+	struct nfs3_createargs	arg;
 	struct nfs3_diropres	res = { &dir_attr, fhandle, fattr };
 	int			status;
+
+	arg.fh = NFS_FH(dir);
+	arg.name = name->name;
+	arg.len = name->len,
+	arg.sattr = sattr;
+	arg.createmode = 0;
+	arg.verifier [0] = 0;
+	arg.verifier [1] = 0;
 
 	dprintk("NFS call  mkdir %s\n", name->name);
 	dir_attr.valid = 0;

