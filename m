From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 20 Jun 2017 10:36:50 +0000
Subject: Re: [PATCH 0/7] rwsem: Implement down_read_killable()
Message-Id: <20170620103648.vi7v45mjk63msw72@virtuozzo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.10.1706191327190.95967@chino.kir.corp.google.com>
 <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
 <2406.1497947414@warthog.procyon.org.uk>
In-Reply-To: <2406.1497947414@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>, linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

On Tue, Jun 20, 2017 at 09:30, David Howells wrote:
> David Rientjes <rientjes@google.com> wrote:
> 
> > I would have expected to see down_read_killable() actually used somewhere 
> > after its implementation as part of this patchset.
> 
> There are some places we should be using down_{read|write}_interruptible(), if
> it existed, dressed as inode_lock{,_shared}_interruptible().

Then let's use it in iterate_dir():

[PATCH]fs: Use killable down_read() in iterate_dir()

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
 fs/readdir.c | 11 +++++------
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
