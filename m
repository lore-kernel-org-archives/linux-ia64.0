From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 13 Sep 2005 20:03:48 +0000
Subject: Is git broken?
Message-Id: <200509132003.j8DK3nTd2612486@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Git pull from Tony's test tree isn't working.  Is my syntax wrong or
is there an issue on the kernel.org side?

Thanks,

-----------------------------------------------
attica$ git pull rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git test
MOTD:
MOTD:   Welcome to the Linux Kernel Archive.
MOTD:
MOTD:   Due to U.S. Exports Regulations, all cryptographic software on this
MOTD:   site is subject to the following legal notice:
MOTD:
MOTD:   This site includes publicly available encryption source code
MOTD:   which, together with object code resulting from the compiling of
MOTD:   publicly available source code, may be exported from the United
MOTD:   States under License Exception "TSU" pursuant to 15 C.F.R. Section
MOTD:   740.13(e).
MOTD:
MOTD:   This legal notice applies to cryptographic software only.
MOTD:   Please see the Bureau of Industry and Security,
MOTD:   http://www.bis.doc.gov/ for more information about current
MOTD:   U.S. regulations.
MOTD:

MOTD:
MOTD:   Welcome to the Linux Kernel Archive.
MOTD:
MOTD:   Due to U.S. Exports Regulations, all cryptographic software on this
MOTD:   site is subject to the following legal notice:
MOTD:
MOTD:   This site includes publicly available encryption source code
MOTD:   which, together with object code resulting from the compiling of
MOTD:   publicly available source code, may be exported from the United
MOTD:   States under License Exception "TSU" pursuant to 15 C.F.R. Section
MOTD:   740.13(e).
MOTD:
MOTD:   This legal notice applies to cryptographic software only.
MOTD:   Please see the Bureau of Industry and Security,
MOTD:   http://www.bis.doc.gov/ for more information about current
MOTD:   U.S. regulations.
MOTD:

receiving file list ... done

wrote 113 bytes  read 30799 bytes  20608.00 bytes/sec
total size is 82275235  speedup is 2661.60
* committish: 6c141f61ee4f5fba63d9c54e03cb2faa6877bf1a  refs/heads/test from rsync://rsync.
kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
error: Could not read 9401c705f2a6a7e5df102f6443dba395c3c5e5a8
error: Could not read 357d596bd552ad157a906289ab13ea6ba7e66e3d
Updating from aa2dca4563b0629ecd9d9994dfdf39f29ff1b43f to 6c141f61ee4f5fba63d9c54e03cb2faa6
877bf1a.
fatal: failed to unpack tree object 6c141f61ee4f5fba63d9c54e03cb2faa6877bf1a
attica$

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
