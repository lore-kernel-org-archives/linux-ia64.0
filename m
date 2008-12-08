From: Robin Holt <holt@sgi.com>
Date: Mon, 08 Dec 2008 14:43:46 +0000
Subject: [Patch 0/4] Update generic_defconfig, tweak autofs, and clear section mismatches.
Message-Id: <20081208144346.1A76A156F50D@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I was testing the 218d11a git revision and noticed autofs was not working
on some root filesystems.  This came down to autofs being statically
linked into the kernel and the root's automount expecting only AUTOFS4
being loaded.  After changing AUTOFS=m and AUTOFS4=m, I decided to look
at the remaining section mismatches and realized they are all SGI's so
I fixed those up as well.

Thanks,
Robin
