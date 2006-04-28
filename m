From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 28 Apr 2006 01:23:31 +0000
Subject: Re: Read *pgd again in vhpt_miss handler
Message-Id: <Pine.LNX.4.64.0604271821040.28763@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444F79CA.7060804@bull.net>
In-Reply-To: <444F79CA.7060804@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Apr 2006, Zoltan Menyhart wrote:

> I wanted to use the mm semaphore => no need to walk again the
> pgd ... pte chain.

The pgd ... pte chain does not change even without mmap until 
the usage of the memory area ceases.

