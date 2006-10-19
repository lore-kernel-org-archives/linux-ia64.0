From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 19 Oct 2006 16:43:51 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <Pine.LNX.4.64.0610190942050.8072@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
 <453796BC.8050600@shadowen.org>
In-Reply-To: <453796BC.8050600@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, linux-ia64@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>

On Thu, 19 Oct 2006, Andy Whitcroft wrote:

> This is a good thing too as one of the main issues we've had with the
> VIRTUAL_MEMMAP stuff is this need to pfn_valid each and every
> conversion.  Of course the same change could be applied there just as well.

Well it should have been done instead of adding this strange hole logic.
