From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Mon, 21 Aug 2000 15:44:35 +0000
Subject: [Linux-ia64] 2.4.0-test6 boot problems
Message-Id: <marc-linux-ia64-105590678205358@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have a Lion w/ 3gb of RAM, 2gb of which begins at 0x100000000 physical
(i.e. 4gb), that will not boot 2.4.0-test6 unless we limit it to using the
memory below 4gb.  The system panics because it is unable to mount the root
file system.  Root cannot be mounted because we do not find a valid partiton
table on the disk (note that this same disk boots test4 fine and will boot
test6 with memory restricted to below 4gb).

We don't find a partition table because the bread() of it fails.  We don't
get an I/O error, but rather it seems the read isn't being placing the data
into the chosen buffer.  I verifed this by placing debug code into bread().
I pre-fill the buffer with all ones (0xfff.....) and the buffer is unchanged
upon completion of the read.  I suspect the problem may lie within the
CONFIG_SWIOTLB, it seems we're truncating the upper 32 bits somewhere.

Has anyone else come across this, or know if a fix exists?  I'd be happy to
try out a patch if one exists.

Thanks,

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



