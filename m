From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Mar 2006 21:46:09 +0000
Subject: RE: unlock_buffer() and clear_bit()
Message-Id: <200603242145.k2OLjog18835@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44240DB3.3040502@bull.net>
In-Reply-To: <44240DB3.3040502@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, March 24, 2006 7:18 AM
> I wonder if "unlock_buffer()" works correctly on ia64...
> 
> As far As I can see, nothing makes it sure that data modifications
> issued inside the critical section be globally visible before the
> "BH_Lock" bit gets cleared.


Are you saying the memory ordering in unlock_buffer() is x86 centric
that relies on arch specific write ordering? (on x86, write to memory
implies a release semantics w.r.t. read proceed it).  It's better to
bring this up on LKML.  If your concern is true, then it is a bug in
the generic code that lacks smp_mb__before_clear_bit.

- Ken

