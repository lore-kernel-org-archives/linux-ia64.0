From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 30 Sep 2003 18:06:46 +0000
Subject: Re: Problem using more than 2 GB with my driver
Message-Id: <marc-linux-ia64-106494522210942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106494885715850@msgid-missing>
In-Reply-To: <marc-linux-ia64-106494885715850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-09-30 at 11:49, Grant Grundler wrote:
> On Tue, Sep 30, 2003 at 04:13:30PM +0200, Patrice Martinez wrote:
> > I wrote a driver using the physical addresses of a buffer computed by
> > the "ia64_tpa" function (but no using DMA) that works only on machines
> > with 2Gb of RAM at most. With more RAM, the machine crashes very badly
> > after a while, and even KDB is not usable...
> > If anybody has an a idea ;-)
> 
> Which machine is this on?
> rx2600/rx5670 has a memory hole from 2-4GB because of IO "stuff".
> ie memory > 2G ends up getting placed above 4GB physical.
> 

   Minor correction, on zx1, memory in the 1-4GB range is relocated.  So
there's actually only 1GB of memory below 4GB.

	Alex 

-- 
Alex Williamson                             HP Linux & Open Source Lab

