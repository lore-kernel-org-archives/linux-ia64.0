From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 24 Mar 2005 18:41:06 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <Pine.LNX.4.58.0503241038040.5663@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
 <200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
 <200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
 <20050318192808.GB38053@muc.de> <16963.2075.713737.485070@napali.hpl.hp.com>
In-Reply-To: <16963.2075.713737.485070@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andi Kleen <ak@muc.de>, Christoph Lameter <clameter@sgi.com>, Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Thu, 24 Mar 2005, David Mosberger wrote:

> That's definitely the case.  See my earlier post on this topic:
>
>   http://www.gelato.unsw.edu.au/linux-ia64/0409/11012.html
>
> Unfortunately, nobody reported any results for larger machines and/or
> more interesting workloads, so the patch is in limbo at this time.
> Clearly, if the CPU that's clearing the page is likely to use that
> same page soon after, it'd be useful to use temporal stores.


So it would be useful to have

clear_page 	-> Temporal. Only zaps one page

	and

clear_pages	-> Zaps arbitrary order of page non-temporal


Rework the clear_pages patch to do just that? Maybe rename clear_pages
clear_pages_nt?

prep_zero_page would use a temporal clear for an order 0 page but a
nontemporal clear for higher order pages.
