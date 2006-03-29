From: Grant Grundler <iod00d@hp.com>
Date: Wed, 29 Mar 2006 23:50:53 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <20060329235053.GC541@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com> <200603292348.k2TNmNg12952@unix-os.sc.intel.com>
In-Reply-To: <200603292348.k2TNmNg12952@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 03:49:08PM -0800, Chen, Kenneth W wrote:
> Is gcc smart enough to turn constant argument and collapse inline of
> inline function?  I hope it does.

Yes, I'm pretty sure at -O2 (normal kernel usage) it is.

grant
