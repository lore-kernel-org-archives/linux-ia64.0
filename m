From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Nov 2004 18:53:07 +0000
Subject: RE: [PATCH] top level scheduler domain for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F024B7E02@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> >  if (numnodes <= SMALL_SYSTEM_THRESHOLD) {
>> >   SD_NODES_PER_DOMAIN = numnodes;
>> >   build_node_domains(); /* each one spans the system */
>> >  } else {
>> >   SD_NODES_PER_DOMAIN = 4; /* or whatever */

Ugh!  The magic '4' is going to be different for different machines,
so there is no value that will make all of the people happy all of
the time.

>Yeah, but still the same number of CPUs/FSB.  I agree that 
>autotuning would be 
>best (the above is a crude example of that).  Any suggestions?

Can't you use the SLIT table to build a hierachy of scheduler
domains that matches the actual hardware configuration, instead
of using compiled in constants or even boot-time command line
parameters?

-Tony
