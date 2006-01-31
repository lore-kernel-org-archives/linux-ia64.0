From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 16:25:37 +0000
Subject: RE: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <200601311625.k0VGPjg17851@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
In-Reply-To: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote on Tuesday, January 31, 2006 3:01 AM
> Ken> Keith Owens wrote on Tuesday, January 31, 2006 12:57 AM
> >> The cache lines are not guaranteed to be 128 byte aligned, they
> >> were 64 on bigsur.  Change 127 to (L1_CACHE_BYTES - 1).
> 
> Ken> That did cross my mind and L1_CACHE_BYTES is such a misleading
> Ken> name.  In my head, L1 means the cache level closest to the CPU
> Ken> core, but here it appears to represent last level cache line.  Do
> Ken> we have the numbering scheme reversed?  I have no idea what's
> Ken> going on here.
> 
> Shouldn't this be SMP_CACHE_BYTES if anything?


Yeah, if nobody cares about UP performance. SMP_CACHE_BYTES is 8 bytes
on UP kernel (though it doesn't seem that anyone cares about UP).  I
will consult Tony to see what he likes.  I might settle with
L1_CACHE_BYTES.  I can just see people is going yell at me for having
125 column line :-p  :-))

- Ken

