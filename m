From: Jack Steiner <steiner@sgi.com>
Date: Thu, 06 Nov 2003 17:43:36 +0000
Subject: Re: [PATCH] - Increase max number of nodes (cpu_to_node_map)
Message-Id: <marc-linux-ia64-106814122107380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106806288024897@msgid-missing>
In-Reply-To: <marc-linux-ia64-106806288024897@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 06, 2003 at 05:06:04PM +0000, Matthew Wilcox wrote:
> On Wed, Nov 05, 2003 at 01:44:17PM -0600, Jack Steiner wrote:
> > I hit a problem with systems having > 256 nodes. The
> > cpu_to_node_map array is an array of char - needs to be 
> > bigger.
> > 
> > Here is a patch that changes it to a short.
> 
> shouldn't that be an unsigned short so we don't run into problems
> when adding the 32769th processor?


Either signed or unsigned works for me. 

I didnt initially make it unsigned because a number of structures use 
negative values to indicate non-existant cpus or nodes. However, that 
doesnt currently apply in this case.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


