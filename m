From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Oct 2003 18:05:11 +0000
Subject: Re: [PATCH] fix topology initialization
Message-Id: <marc-linux-ia64-106641410030983@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641334730082@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641334730082@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 10:48:34AM -0700, Jesse Barnes wrote:
> Now that NUMA kernels are working we can properly initialze the topology
> information so that /sys/devices/system/node* & friends aren't empty.

So with a proper topology API we can start to kill off the topology-related
hwgfs mess?

