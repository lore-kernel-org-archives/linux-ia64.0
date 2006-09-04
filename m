From: Jes Sorensen <jes@sgi.com>
Date: Mon, 04 Sep 2006 07:43:35 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <yq0ac5ghyag.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Horms" = Horms  <horms@verge.net.au> writes:

Horms> Hi, I'm trying to build a non-NUMA (HP_SIM) config, and I am
Horms> running into trouble because there are serveral places where
Horms> NODE_DATA is used. It seems to me that this makes little sense
Horms> as NODE_DATA needs the node_data element of struct
Horms> cpuinfo_ia64, which doesn't exist without CONFIG_NUMA.

Horms> Is CONFIG_NUMA mandatory or is this just an oversight?

I haven't looked at the details, given you don't say where it breaks,
but it would make sense to me that a non-NUMA system is treated as a
single node system, eg. NODE_DATA(0) ought to be valid.

Cheers,
Jes

-- 
VGER BF report: U 0.501786
