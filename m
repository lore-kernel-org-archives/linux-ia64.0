From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Feb 2008 18:53:41 +0000
Subject: Re: [PATCH] Reduce per_cpu allocations to the minimum needed for
Message-Id: <Pine.LNX.4.64.0802121052410.1640@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080211175918.GO3875@sgi.com>
In-Reply-To: <20080211175918.GO3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Feb 2008, Robin Holt wrote:

> Please don't apply this yet.  I just noticed the CONFIG_FLATMEM configs
> did not work.  I will look at this more this evening.

That reminds me: I have a patch to remove all other memory models except 
for SPARSE_VMEMMAP for ia64 somewhere.... If we would merge that then 
maintaining ia64 may become simpler.

