From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Fri, 27 Feb 2004 00:56:45 +0000
Subject: Re: [Lse-tech] Re: fix zonelist ordering for NUMA
Message-Id: <124100000.1077843405@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <100070000.1077834062@flay>
In-Reply-To: <100070000.1077834062@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--On Thursday, February 26, 2004 16:47:10 -0800 Chris Wedgwood <cw@f00f.org> wrote:

> On Thu, Feb 26, 2004 at 02:21:02PM -0800, Martin J. Bligh wrote:
> 
>> +#ifndef node_distance
>> +#define node_distance(from,to) (1)
>> +#endif
> 
> 1 or 0 here?

Dunno ... was from j-nomura@ce.jp.nec.com, but I'd guess 1 makes more
sense semantically - we're saying the distance between nodes on a flat
NUMA architecture is equal (I think ;-))

M.

