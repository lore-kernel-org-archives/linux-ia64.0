From: Jes Sorensen <jes@sgi.com>
Date: Tue, 21 Feb 2006 11:23:12 +0000
Subject: Re: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <yq0r75x6jmn.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214162337.GA16954@sgi.com>
	<20060220201713.GA4992@infradead.org> <20060221024710.GB30226@sgi.com>
	<20060221103633.GA19349@infradead.org>
In-Reply-To: <20060221103633.GA19349@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Mark Maule <maule@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

Christoph> On Mon, Feb 20, 2006 at 08:47:10PM -0600, Mark Maule wrote:
>> All I'm doing by exporting sn_pcidev_info_get is allowing a module
>> to use the SGI SN_PCIDEV_BUSSOFT() macro which will tell a driver
>> which piece of altix PCI hw its device is sitting behind
>> (e.g. PCIIO_ASIC_TYPE_TIOCP et. al).

Christoph> And that's absolutely not something a driver should care
Christoph> about.  If you illegal binary driver uses it it's totally
Christoph> broken (but then we knew that before anyway ;-))

Christoph,

Leaving the issues around the specific client aside here.

Any chance you could explain why some drivers in drivers/net use the
arch defines to set things like optimial burst sizes then?  Drivers
such as acenic.c, fealnx.c and starfire.c do this based on the arch
even though it really is a property of the combination of the PCI bus,
CPU and memory busses in the specific systems.

Were you planning on posting a patch to remove all of those instances
while you were at it?

Point is that there are cases where tuning requires you to know what
PCI bridge is below you in order to get the best performance out of a
card. One can keep a PCI ID blacklist to handle tuning of the PCI
bridge itself, but it can't handle things that needs to be tuned
by setting the PCI device's own registers.

Having a generic API to export this information would be a good thing
IMHO.

Cheers,
Jes
