From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 18 Mar 2005 20:19:50 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <Pine.LNX.4.58.0503181217530.17596@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
 <200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
 <200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
 <20050318192808.GB38053@muc.de>
In-Reply-To: <20050318192808.GB38053@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Fri, 18 Mar 2005, Andi Kleen wrote:

> It does not make any sense if you think of it - the memory bus
> of the CPU cannot be that much faster than the cache.

The memory bus would be able to reach a higher rate if properly optimized
for sequential writes to memory. A cache typically does random writes.
