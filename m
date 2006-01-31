From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 19:48:02 +0000
Subject: FW: [patch 1/6] remove dead code in ia64_leave_kernel
Message-Id: <200601311948.k0VJmAg03598@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310907.k0V976g12698@unix-os.sc.intel.com>
In-Reply-To: <200601310907.k0V976g12698@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just did a reply on the original mail.  Forwarding my response.

-----Original Message-----
From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com] 
Sent: Tuesday, January 31, 2006 11:42 AM
To: 'David Mosberger-Tang'
Subject: RE: [patch 1/6] remove dead code in ia64_leave_kernel

David Mosberger-Tang wrote on Tuesday, January 31, 2006 9:51 AM
> Be careful here.  Signal-delivery triggers some strange corner-cases. 
> I don't have this all in my head at the moment, but one tricky part is
> returning from a signal-handler, where you enter the kernel as a
> syscall, but leave it as a non-syscall (usually).  I trust that you
> already checked this case, but wanted to make sure the point isn't
> lost.

Thanks for the warning, I don't think I checked that corner case. I will
look at it again.


> Also, I believe with your patch, you'll end up consuming the read of
> ar.bsp which could adversely affect the latency of syscalls
> (especially when everything is cached).  Did you check on this?

Kernel currently consumes the read of ar.bsp, since it has to preserve
the current frame, and it does so by doing two ar.bsp read: once before
cover instruction, and once after to calculate new ndirty value to be
loaded into ar.rsc.  I'm not changing the order or location of these
ar.bsp reads in this patch.  The code that I moved are always executed
for syscall leave.

Having said that, I have a craze idea of optimize away two bsp reads
along with cover instruction in the syscall leave path.  I'm still
exploring whether that is achievable or not.  If we can do that, then
all that latency would go away along with the code that this patch moved.

- Ken

