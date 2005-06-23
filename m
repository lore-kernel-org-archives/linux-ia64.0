From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 23 Jun 2005 21:20:08 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <Pine.LNX.4.62.0506231417500.13272@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Jun 2005, Jesse Barnes wrote:

> It looks like you're adding the new 'node' field unconditionally, but 
> protecting the sba assignment by CONFIG_NUMA?  Which one is wrong? :)

if !CONFIG_NUMA then the node field exists but is always -1, which will 
result in node unspecific allocations.

