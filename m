From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 01:13:35 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310112.k2V1Cpg27150@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301707300.2553@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 5:09 PM
> In general yes the caller should not be thinking about clear_bit having 
> any memory ordering at all. However for IA64 arch specific code the bit 
> operations must have a certain ordering semantic and it would be best that 
> these are also consistent. clear_bit is not a lock operation and may 
> f.e. be used for locking something.

OK, fine.  Then please don't change smp_mb__after_clear_bit() for ia64.
i.e., leave it alone as noop.

- Ken
