From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 03:11:47 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310311.k2V3B3g28498@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301907070.3145@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Zoltan Menyhart' <Zoltan.Menyhart@bull.net>, "'Boehm, Hans'" <hans.boehm@hp.com>, "'Grundler, Grant G'" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 7:09 PM
> I was referring to the LOCK prefix. Doesnt that insure the processor to 
> go into a special state and make the bus go into a special state that 
> implies a barrier?

Yes, that's why on i386 both smp_mb__before_clear_bit() and 
smp_mb__after_clear_bit() are noop.
