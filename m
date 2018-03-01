From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Thu, 01 Mar 2018 23:37:20 +0000
Subject: [RFC 1/5] seq_file: introduce seq_open_data helper
Message-Id: <20180301233724.20440-1-linux@rasmusvillemoes.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

There are quite a few callers of seq_open that could be simplified by
setting the ->private member via the seq_open call instead of fetching
file->private_data afterwards.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
I've just included a few examples of possible users of this helper,
there are many more similar cases. As a bonus, the first two fix
potential NULL derefs (if one believes that seq_open can actually
fail).

seq_open_private would have been a better name, but that one is
already taken...

Documentation/filesystems/seq_file.txt | 9 +++++----
 fs/seq_file.c                          | 9 ++++++++-
 include/linux/seq_file.h               | 1 +
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/seq_file.txt b/Documentation/filesystems/seq_file.txt
index 9de4303201e1..68571b8275d8 100644
--- a/Documentation/filesystems/seq_file.txt
+++ b/Documentation/filesystems/seq_file.txt
@@ -234,10 +234,11 @@ Here, the call to seq_open() takes the seq_operations structure we created
 before, and gets set up to iterate through the virtual file.
 
 On a successful open, seq_open() stores the struct seq_file pointer in
-file->private_data. If you have an application where the same iterator can
-be used for more than one file, you can store an arbitrary pointer in the
-private field of the seq_file structure; that value can then be retrieved
-by the iterator functions.
+file->private_data. If you have an application where the same iterator
+can be used for more than one file, you can store an arbitrary pointer
+in the private field of the seq_file structure; that value can then be
+retrieved by the iterator functions. Using the wrapper seq_open_data()
+allows you to set the initial value for that field.
 
 There is also a wrapper function to seq_open() called seq_open_private(). It
 kmallocs a zero filled block of memory and stores a pointer to it in the
diff --git a/fs/seq_file.c b/fs/seq_file.c
index eea09f6d8830..f2145cb6e23d 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -45,7 +45,7 @@ static void *seq_buf_alloc(unsigned long size)
  *	Note: seq_open() will allocate a struct seq_file and store its
  *	pointer in @file->private_data. This pointer should not be modified.
  */
-int seq_open(struct file *file, const struct seq_operations *op)
+int seq_open_data(struct file *file, const struct seq_operations *op, void *data)
 {
 	struct seq_file *p;
 
@@ -59,6 +59,7 @@ int seq_open(struct file *file, const struct seq_operations *op)
 
 	mutex_init(&p->lock);
 	p->op = op;
+	p->private = data;
 
 	// No refcounting: the lifetime of 'p' is constrained
 	// to the lifetime of the file.
@@ -85,6 +86,12 @@ int seq_open(struct file *file, const struct seq_operations *op)
 }
 EXPORT_SYMBOL(seq_open);
 
+int seq_open(struct file *file, const struct seq_operations *op)
+{
+	return seq_open_data(file, op, NULL);
+}
+EXPORT_SYMBOL(seq_open_data);
+
 static int traverse(struct seq_file *m, loff_t offset)
 {
 	loff_t pos = 0, index;
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index ab437dd2e3b9..f5ff376fa62b 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -107,6 +107,7 @@ void seq_pad(struct seq_file *m, char c);
 
 char *mangle_path(char *s, const char *p, const char *esc);
 int seq_open(struct file *, const struct seq_operations *);
+int seq_open_data(struct file *, const struct seq_operations *, void *);
 ssize_t seq_read(struct file *, char __user *, size_t, loff_t *);
 loff_t seq_lseek(struct file *, loff_t, int);
 int seq_release(struct inode *, struct file *);
-- 
2.15.1

