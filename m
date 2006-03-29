From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 23:50:31 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603291550050.26228@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603292348.k2TNmNg12952@unix-os.sc.intel.com>
In-Reply-To: <200603292348.k2TNmNg12952@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 29 Mar 2006, Chen, Kenneth W wrote:

> Is gcc smart enough to turn constant argument and collapse inline of
> inline function?  I hope it does.

Sure we use that all the time. Look at the cmpxchg definition in 
asm-ia64/system.h
