From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 31 Aug 2006 17:39:58 +0000
Subject: Re: [RFC][PATCH 4/9] ia64 generic PAGE_SIZE
Message-Id: <Pine.LNX.4.64.0608311039260.12416@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain> 
 <20060830221607.1DB81421@localhost.localdomain> 
 <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
 <1157045910.31295.23.camel@localhost.localdomain>
In-Reply-To: <1157045910.31295.23.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 31 Aug 2006, Dave Hansen wrote:

> > #define KERNEL_STACK_SIZE_ORDER (max(0, 15 - PAGE_SHIFT)) 
> 
> My next series will be to clean up stack size handling.  Do you mind if
> it waits until then?

I am not in a hurry on this one.


