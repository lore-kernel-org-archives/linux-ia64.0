From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 29 Sep 2017 16:06:48 +0000
Subject: [PATCH REBASED 6/6] fs: Use killable down_read() in iterate_dir()
Message-Id: <150670120820.23930.5455667921545937220.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
In-Reply-To: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

There was mutex_lock_interruptible() initially, and it was changed
to rwsem, but there were not killable rwsem primitives that time.
From commit 9902af79c01a:

    "The main issue is the lack of down_write_killable(), so the places
     like readdir.c switched to plain inode_lock(); once killable
     variants of rwsem primitives appear, that'll be dealt with"

Use down_read_killable() same as down_write_killable() in !shared
case, as concurrent inode_lock() may take much time, that may be
wanted to be interrupted by user.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/readdir.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/readdir.c b/fs/readdir.c
index 89659549c09d..7c584bbb4ce3 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -36,13 +36,12 @@ int iterate_dir(struct file *file, struct dir_context *ctx)
 	if (res)
 		goto out;
 
-	if (shared) {
-		inode_lock_shared(inode);
-	} else {
+	if (shared)
+		res = down_read_killable(&inode->i_rwsem);
+	else
 		res = down_write_killable(&inode->i_rwsem);
-		if (res)
-			goto out;
-	}
+	if (res)
+		goto out;
 
 	res = -ENOENT;
 	if (!IS_DEADDIR(inode)) {

