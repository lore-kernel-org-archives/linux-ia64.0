From: Grant Grundler <iod00d@hp.com>
Date: Tue, 30 Sep 2003 17:49:38 +0000
Subject: Re: Problem using more than 2 GB with my driver
Message-Id: <marc-linux-ia64-106494437309740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106494885715850@msgid-missing>
In-Reply-To: <marc-linux-ia64-106494885715850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 30, 2003 at 04:13:30PM +0200, Patrice Martinez wrote:
> I wrote a driver using the physical addresses of a buffer computed by
> the "ia64_tpa" function (but no using DMA) that works only on machines
> with 2Gb of RAM at most. With more RAM, the machine crashes very badly
> after a while, and even KDB is not usable...
> If anybody has an a idea ;-)

Which machine is this on?
rx2600/rx5670 has a memory hole from 2-4GB because of IO "stuff".
ie memory > 2G ends up getting placed above 4GB physical.

Sounds like your code is using one or more of:
1) unsigned int
2) signed int -> signed long (automatic conversion for math).
3) linear addressing (not aware of memory holes)

And I'm curious as well what your driver does with physical addresses...
It's obviously not DMA since that wouldn't work on most of the ia64 machines
out there today.

grant
