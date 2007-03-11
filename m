From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 16:44:20 +0000
Subject: Re: [QUICKLIST 4/6] x86_64: Single Quicklist
Message-Id: <Pine.LNX.4.64.0703110939140.24216@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
 <20070311020944.19905.87599.sendpatchset@schroedinger.engr.sgi.com>
 <200703110854.05799.ak@suse.de>
In-Reply-To: <200703110854.05799.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, mpm@selenic.com

On Sun, 11 Mar 2007, Andi Kleen wrote:

> This and i386 version are ok to me, although it might be better to just
> finish __GFP_ZERO support to do this.

This would not work for pgds on i386 and x86_64

GFP_ZERO support the way I have done it in the past would mean another set 
of buddy lists in the page allocator and another issue with fragmentation. 
So I have stayed away from it although patches exist in my archives (See 
my ftp.kernel.org archive).

Maybe we could implemento limited GFP_ZERO support by just keeping an 
additional per cpu list of pages? The issue with that one is that a page
may grow cold on that list. One usually want the page to be hot in the 
cache when it is allocated. This is different for page table pages. Page 
table pages are typically sparsely accessed.
