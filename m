From: Jim Wilson <wilson@specifixinc.com>
Date: Fri, 06 Feb 2004 09:49:57 +0000
Subject: Re: gcc problems
Message-Id: <1076060998.13511.110.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-02-06 at 00:00, Andrew Morton wrote:
> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c: In function `uw_frame_state_for':
> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure has no member named `sc_rbs_base'
> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure has no member named `sc_loadrs'

This is from the MD_FALLBACK_FRAME_STATE_FOR macro in
gcc/config/ia64/linux.h, which handles machine and OS dependent
unwinding from signal handers.  It uses signal.h and sys/context.h. 
These are things that could have perhaps changed with a new kernel or
glibc.  If the signal context structure has changed, then we need a new
version of this code, and will somehow have to choose the right one.

The easiest workaround is probably to install libunwind on your system
before trying to build gcc.  Then none of this ugly code is needed,
because libunwind gracefully handles it all for us.  Assuming libunwind
builds on the new kernels, but I would be surprised if it didn't.  If
libunwind is installed, then gcc uses it automatically, so you don't
have to configure gcc differently.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

