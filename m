From: Andrew Morton <akpm@osdl.org>
Date: Thu, 03 Mar 2005 21:20:11 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <20050303132011.7c80033d.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
	<20050302174507.7991af94.akpm@osdl.org>
	<Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
	<20050302185508.4cd2f618.akpm@osdl.org>
	<Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
	<20050302201425.2b994195.akpm@osdl.org>
	<Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com>
	<20050302205612.451d220b.akpm@osdl.org>
	<Pine.LNX.4.58.0503022206001.4389@schroedinger.engr.sgi.com>
	<20050302222008.4910eb7b.akpm@osdl.org>
	<Pine.LNX.4.58.0503030852490.8941@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503030852490.8941@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 2 Mar 2005, Andrew Morton wrote:
> 
>  > >  This is not relevant since it only deals with file pages.
>  >
>  > OK.   And CONFIG_DEBUG_PAGEALLOC?
> 
>  Its a debug feature that can be fixed if its broken.

It's broken.

A fix would be to restore the get_page() if CONFIG_DEBUG_PAGEALLOC.  Not
particularly glorious..

