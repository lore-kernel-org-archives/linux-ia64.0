From: Jack Steiner <steiner@sgi.com>
Date: Thu, 04 Nov 2004 19:36:29 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041104193629.GA22887@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com> <20041104141337.GA18445@sgi.com> <200411041631.42627.efocht@hpce.nec.com> <20041104170435.GA19687@wotan.suse.de>
In-Reply-To: <20041104170435.GA19687@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Erich Focht <efocht@hpce.nec.com>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 04, 2004 at 06:04:35PM +0100, Andi Kleen wrote:
> On Thu, Nov 04, 2004 at 04:31:42PM +0100, Erich Focht wrote:
> > On Thursday 04 November 2004 15:13, Jack Steiner wrote:
> > > I think it would also be useful to have a similar cpu-to-cpu distance
> > > metric:
> > > ????????% cat /sys/devices/system/cpu/cpu0/distance
> > > ????????10 20 40 60 
> > > 
> > > This gives the same information but is cpu-centric rather than
> > > node centric.
> > 
> > I don't see the use of that once you have some way to find the logical
> > CPU to node number mapping. The "node distances" are meant to be
> 
> I think he wants it just to have a more convenient interface,
> which is not necessarily a bad thing.  But then one could put the 
> convenience into libnuma anyways.
> 
> -Andi

Yes, strictly convenience.  Most of the cases that I have seen deal with
cpu placement & cpu distances from each other. I agree that cpu-to-cpu
distances can be determined by converting to nodes & finding the 
node-to-node distance.

A second reason is symmetry. If there is a /sys/devices/system/node/node0/distance
metric, it seems as though there should also be a /sys/devices/system/cpu/cpu0/distance
metric.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


