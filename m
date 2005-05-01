From: Keith Owens <kaos@sgi.com>
Date: Sun, 01 May 2005 04:19:28 +0000
Subject: Re: BK to GIT migration status for ia64
Message-Id: <1469.1114921168@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 28 Apr 2005 12:19:49 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>1) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
>2) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/test-2.6.git

Neither tree contains a refs or heads directory.  Other git trees like
linux and davem have these directories.  cogito cg-clone and cg-update
expect to find refs and heads.

# ls -l /pub/scm/linux/kernel/git/torvalds/linux-2.6.git
total 16
lrwxrwxrwx    1 torvalds torvalds   17 Apr 27 10:09 HEAD -> refs/heads/master
-rw-r--r--    1 torvalds torvalds   41 Apr 30 15:42 MERGE_HEAD
-rw-rw-r--    1 torvalds torvalds   41 Apr 30 15:42 ORIG_HEAD
drwxr-xr-x  258 torvalds torvalds 4096 Apr 25 08:23 objects
drwxrwxr-x    3 torvalds torvalds 4096 Apr 26 15:23 refs
# ls -l /pub/scm/linux/kernel/git/davem/net-2.6.git
total 1612
lrwxrwxrwx    1 davem davem      17 Apr 28 12:38 HEAD -> refs/heads/master
-rw-r--r--    1 davem davem      41 Apr 17 20:01 MERGE-HEAD
-rw-rw-r--    1 davem davem      41 Apr 27 10:05 MERGE_HEAD
-rw-rw-r--    1 davem davem      41 Apr 27 10:05 ORIG_HEAD
drwxrwxr-x    2 davem davem    4096 Apr 20 16:38 heads
-rw-------    1 davem davem 1620168 Apr 28 12:16 index
drwxr-sr-x  258 davem davem    4096 Apr 21 10:21 objects
drwxrwxr-x    3 davem davem    4096 Apr 26 15:23 refs
# ls -l /pub/scm/linux/kernel/git/aegl/linux-2.6.git
total 12
-rw-rw-r--    1 aegl ftpadmin   41 Apr 27 14:36 HEAD
-rw-rw-r--    1 aegl ftpadmin   38 Apr 29 17:24 description
drwxr-sr-x  258 aegl ftpadmin 4096 Apr 21 10:21 objects
# ls -l /pub/scm/linux/kernel/git/aegl/test-2.6.git/
total 12
-rw-rw-r--    1 aegl ftpadmin   41 Apr 27 21:22 HEAD
-rw-rw-r--    1 aegl ftpadmin   36 Apr 29 17:25 description
drwxr-sr-x  258 aegl ftpadmin 4096 Apr 27 21:39 objects


