From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 00:26:15 +0000
Subject: RE: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <Pine.LNX.4.64.0610121725040.22717@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Oct 2006, Chen, Kenneth W wrote:

> I like the concept a lot.

Thanks.

> > - This patch will enable later patches to move the virtual memory map into
> >   another region with a larger page size. Larger page sizes will reduce
> >   TLB pressure.
> 
> I like that even more, which region are you going to move it to?

I thought about region 7 and I think I could use some help with the ivt
asssembly ... Will post the RFC in a minute.

