From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 07 Sep 2005 01:49:01 +0000
Subject: RE: [patch] make exception handler in copy_user more robust
Message-Id: <200509070149.j871ngg21547@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062306.j86N64g19803@unix-os.sc.intel.com>
In-Reply-To: <200509062306.j86N64g19803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

david mosberger wrote on Tuesday, September 06, 2005 6:11 PM
> Since we no longer support GCC 2.x, could that code perhaps be
> simplified by taking advantage of tags?

Maybe, that would get rid of the guessing of where the fault address
is (which is the source of current vulnerability under unusual
condition).  Lots of code in the exception handler is to figure out
how far the software pipeline has started and it tries to copy the
remaining bytes that are still in-flight in the pipeline stage. This
won't change with or without tag support.  When I wrote the code, I
tried to be precise and copy as much byte as I can (even in the
exception handler).  Maybe we don't need that kind of byte granularity
when fault happens.  Does anyone need precise partial copy_user,
meaning copy all the bytes up until faulting address?

- Ken

