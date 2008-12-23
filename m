From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 23 Dec 2008 06:07:54 +0000
Subject: [PATCH 0/5] IA64 ftrace port
Message-Id: <1230012474.10933.97.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
The patches are IA64 ftrace port.
patch 1 is for static ftrace support.
patch 2 - 4 are preparation for IA64 dynamic ftrace support
patch 5 is the actual IA64 dynamic ftrace support.
The patches are against latest -tip tree. They run well in a tiger
machine here.

Tony, I still didn't add unwind for assemble code. It appears other ARCH
doesn't add it too, so maybe there is no real requirement for unwind in
_mcount routines.

Thanks,
Shaohua

