From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 23:49:08 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <200603292348.k2TNmNg12952@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Wednesday, March 29, 2006 3:33 PM
> Hmmm... Maybe we therefore need to add a mode to each bit operation in 
> the kernel?
> 
> With that we can also get rid of the __* version of bitops.
> 
> Possible modes are
> 
> NON_ATOMIC 	Do not perform any atomic ops at all.
> 
> ATOMIC		Atomic but unordered
> 
> ACQUIRE		Atomic with acquire semantics (or lock semantics)
> 
> RELEASE 	Atomic with release semantics (or unlock semantics)
> 
> FENCE		Atomic with full fence.
> 
> This would require another bitops overhaul.
> 
> Maybe we can preserve the existing code with bitops like __* mapped to 
> *(..., NON_ATOMIC) and * mapped to *(..., FENCE) and the gradually fix the 
> rest of the kernel.


Is gcc smart enough to turn constant argument and collapse inline of
inline function?  I hope it does.

Lots of other comments on actual code, but I will defer that until
some consensus is made on the API.  This would be nice to have.

- Ken
