From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Thu, 26 Feb 2004 22:21:02 +0000
Subject: Re: [Lse-tech] Re: fix zonelist ordering for NUMA
Message-Id: <100070000.1077834062@flay>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



--On Wednesday, February 25, 2004 08:54:09 -0800 Jesse Barnes <jbarnes@sgi.com> wrote:

> On Wed, Feb 25, 2004 at 02:01:16PM +0900, j-nomura@ce.jp.nec.com wrote:
>> >   1) make it arch independent
>> >      this means having arch code populate a SLIT-like table for use by
>> >      the generic zonelist building code
>> 
>> I would like to hear the comments from people on other arch.
>> If the same ordering rule can be applicable for others, it's nice.
> 
> Martin, does a scheme like this sound ok with you?  Arch specific code
> would populate a node distance table, which would be used to build each
> pgdat->zonelist in a smarter way than we do currently.

Yeah, looks sensible to me. We probably ought to do this:

+#ifndef node_distance
+#define node_distance(from,to) (1)
+#endif

in the generic fallback topology headers, not in the mm/ .c files. Matt?

Also, I seem to recall those build_zonelists functions are used for both
NUMA and UMA ... now they're getting complex enough that it's probably
worth making a specific non-NUMA version, if only for the sanity of
99% of the poor souls trying to work out how a UMA machine lays it out ;-)

It looks like it won't change ordering for existing boxes with single
layer flat NUMA topologies (round-robin), but we probably ought to check
that carefully ;-)

M.

