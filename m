From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 11 Nov 2004 01:14:31 +0000
Subject: RE: [PATCH] make INIT# handler call panic
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F025E81D3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>    1) dump register state (for all CPUs, not just the INIT monarch)
>>       on the console

>I'll see what I can do about most of these. Part 1 would be
>difficult since the hardware/firmware we've currently got 
>available makes both processors the monarch on INIT.

You could change the call to ia64_sal_set_vectors in ia64_mca_init
to point all cpus to just one routine (pass pointer to the same
routine for monarch/slave) ... and then have the OS init code
handle the serialization.  That would work on both correct and
buggy SAL implementations.

-Tony
