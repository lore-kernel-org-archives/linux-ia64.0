From: Andi Kleen <ak@suse.de>
Date: Thu, 04 Nov 2004 06:37:16 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041104063716.GA28895@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com> <20041104040713.GC21211@wotan.suse.de> <20041104.135721.08317994.t-kochi@bq.jp.nec.com>
In-Reply-To: <20041104.135721.08317994.t-kochi@bq.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Cc: ak@suse.de, steiner@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 04, 2004 at 01:57:21PM +0900, Takayoshi Kochi wrote:
> Hi,
> 
> From: Andi Kleen <ak@suse.de>
> Subject: Re: Externalize SLIT table
> Date: Thu, 4 Nov 2004 05:07:13 +0100
> 
> > > Why not export node_distance() under sysfs?
> > > I like (1).
> > > 
> > > (1) obey one-value-per-file sysfs principle
> > > 
> > > % cat /sys/devices/system/node/node0/distance0
> > > 10
> > 
> > Surely distance from 0 to 0 is 0?
> 
> According to the ACPI spec, 10 means local and other values
> mean ratio to 10.  But what the distance number should mean

Ah, missed that. ok I guess it makes sense to use the same
encoding as ACPI, no need to be intentionally different.

> mean is ambiguous from the spec (e.g. some veondors interpret as
> memory access latency, others interpret as memory throughput
> etc.)
> However relative distance just works for most of uses, I believe.
> 
> Anyway, we should clarify how the numbers should be interpreted
> to avoid confusion.

Defining it as "as defined in the ACPI spec" should be ok. 
I guess even non ACPI architectures will be able to live with that.

Anyways, since we seem to agree and so far nobody has complained
it's just that somebody needs to do a patch?  If possible make
it generic code in drivers/acpi/numa.c, there won't be anything architecture 
specific in this and it should work for x86-64 too.


-Andi
