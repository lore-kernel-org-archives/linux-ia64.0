From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 10 May 2007 11:45:48 +0000
Subject: Re: [request-for-test] [patch 0/3] [IA64] Allow DISCONTIGMEM without NUMA
Message-Id: <20070510114547.GA18095@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070510101945.495818588@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070510101945.495818588@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 10, 2007 at 07:19:45PM +0900, Simon Horman wrote:
> The following patches relate to allowing DISCONTIG memory to compile
> (and hopefully work) without NUMA. I've tested that they boot, but not much
> beyond that.

Why?  I though we wanted to use virtual mem_map and sparsemem for
holes inside a single node?

