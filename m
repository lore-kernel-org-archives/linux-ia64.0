From: Andrew Morton <akpm@osdl.org>
Date: Fri, 06 Feb 2004 08:00:58 +0000
Subject: gcc problems
Message-Id: <20040206000058.7e928d80.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


gcc-3.3.2/ia64 is falling over here with my current tree so I'm trying to
build gcc-3.4 from current gcc CVS.

But gcc is failing to compile:

../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c: In function `uw_frame_state_for':
../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure has no member named `sc_rbs_base'
../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure has no member named `sc_loadrs'
../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c: In function `uw_update_context':
../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:2013: error: structure has no member named `sc_rbs_base'
../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:2013: error: structure has no member named `sc_loadrs'

I configured gcc with

../gcc-3.4-cvs/configure --disable-checking --enable-languages=c --prefix=/usr/local/gcc-3.4-cvs

Is there some trick to this?  And what is the preferred gcc version for
ia64 kernels?

Thanks.
