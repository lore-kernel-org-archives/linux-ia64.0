From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 17 Oct 2003 19:22:17 +0000
Subject: RE: [PATCH] fix topology initialization
Message-Id: <marc-linux-ia64-106641894303639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641334730082@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641334730082@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there any libnuma code available somewhere (library, kernel patch,
etc)?


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Martin K.
Petersen
Sent: Friday, October 17, 2003 11:51 AM
To: Christoph Hellwig
Cc: davidm@hpl.hp.com; linux-ia64@vger.kernel.org
Subject: Re: [PATCH] fix topology initialization


>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

>> I think this will provide some of the info that hwgfs provides, but
>> not all.  We still need a way to map PCI busses to nodes (or
>> cpumasks, whatever makes sense)

Matthew Dobson has worked on PCI affinity.  I'm on the road this week
and have not had a chance to test his latest patch on Altix yet.


Christoph> We should have this in the topology API already in a
Christoph> generic fashion.  Do you need it in userland aswell?

The tentative plan is to use libnuma to export the information to
application developers.


>> and a way to map nodes & busses to physical, rack mounted bricks.

Christoph> Well, that's a SN-specific thing.  But it could be
Christoph> implemented similar to the current toplogy API.  What do
Christoph> you actually need this for?

System administrator diagnostics.  We'll need to do this with
a set of SN2-specific utilities.

-- 
Martin K. Petersen	Silicon Graphics, Inc.
mkp@sgi.com		http://www.sgi.com/
