From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 08 Dec 2005 21:08:33 +0000
Subject: Re: [PATCH 3/3] Zone reclaim V3: Frequency of failed reclaim attempts
Message-Id: <Pine.LNX.4.62.0512081307200.30567@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208203717.30456.17434.sendpatchset@schroedinger.engr.sgi.com>
 <20051208205241.GR11190@wotan.suse.de>
In-Reply-To: <20051208205241.GR11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>

On Thu, 8 Dec 2005, Andi Kleen wrote:

> For long you don't need get_jiffies_64. On 32bit it would be 32bit
> anyways and on 64bit even normal jiffies is 64bit. So normal
> jiffies would be suffice.

Patch follows.

> But I suspect it would be better to just merge the proper patch
> with the full accounting instead of this kludge.

I would also like to see the full accounting patch to fix this in the 
right way but on the other hand I would like to disentangle different 
patchsets as much as possible. The accounting patch may touch many 
critical code paths.
