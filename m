From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 09:42:59 +0000
Subject: RE: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <200601310943.k0V9h7g15793@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
In-Reply-To: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote on Tuesday, January 31, 2006 12:57 AM
> "Chen, Kenneth W" (on Tue, 31 Jan 2006 00:48:28 -0800) wrote:
> >The bottom of kernel rbs stack is the memory used to spill user
> >dirty stack register partition when entering the kernel.  This
> >space is heavily used on every kernel entry and exit. It deserve
> >having its own dedicated cache line and not to share with tail
> >end of thread_info which is not used heavily.
> >
> >Align the bottom of kernel rbs stack to 128 byte boundary.
> >
> >Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> >
> 
> The cache lines are not guaranteed to be 128 byte aligned, they
> were 64 on bigsur.  Change 127 to (L1_CACHE_BYTES - 1).

That did cross my mind and L1_CACHE_BYTES is such a misleading
name.  In my head, L1 means the cache level closest to the CPU
core, but here it appears to represent last level cache line.
Do we have the numbering scheme reversed?  I have no idea what's
going on here. 

- Ken

p.s. It's amazing people is still using bigsur. Long live Itanium!

