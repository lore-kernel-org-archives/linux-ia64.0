From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 20:56:10 +0000
Subject: RE: [PATCH] Make sched_clock() work in early boot
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04294498@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816195916.GA753838@dragonfly.engr.sgi.com>
In-Reply-To: <20050816195916.GA753838@dragonfly.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> When did this break?  I tried out PRINTK_TIME when it was first added
>> and it worked for me then (but since it didn't look very useful to me
>> I left it off in the config files that I use ... so I haven't tried it
>> since.
>
>It's been broken for me since at least April (which was the first time
>I tried it).

Weird.  The timestamp code in printk() has been using sched_clock()
since the day it was added.  And the implementation of sched_clock()
has used the per-cpu area that whole time too.  But there are clearly
many printk's done before we setup the per-cpu area ... so I wonder
how this ever worked [I have a very clear memory of trying this!].

Also interesting is that even with your fix, there is something
wrong with the code ... the first few lines of output are lost
output starts with:

 of memory at 0x85000 due to granule hole at 0x0
[   0.000000] efi.trim_bottom: ignoring ...


Finally, while your patch is compact and neat, I have to agree
with David that depending on the locked TR entry for the per-cpu
area is an assumption that I'd prefer not to hardwire into more
places.

-Tony
