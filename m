From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Sep 2003 15:45:16 +0000
Subject: RE: Problem using more than 2 GB with my driver
Message-Id: <marc-linux-ia64-106493756232354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106494885715850@msgid-missing>
In-Reply-To: <marc-linux-ia64-106494885715850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I've got a little problem:
> I wrote a driver using the physical addresses of a buffer computed by
> the "ia64_tpa" function (but no using DMA) that works only on machines
> with 2Gb of RAM at most. With more RAM, the machine crashes very badly
> after a while, and even KDB is not usable...
> If anybody has an a idea ;-)

What does your driver do with the physical address (if not for DMA, why
does it need the physical address?)

-Tony
