From: "Martin K. Petersen" <mkp@sgi.com>
Date: Wed, 13 Oct 2004 20:37:10 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <yq1655etkw9.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> Ok, I see it now ... the perils of reading the patch rather than
Tony> applying it and looking at the code that you end up with.  I see
Tony> that ia32_mem_init() got dragged along too.

*nod*


Tony> This is pretty messy in terms of code legibility.  

I agree completely.  I never intended for them to permanently live
there.  I was just looking for suggestions for a more appropriate
location.


Tony> Think you can sell LKML on a generic change to initialize this
Tony> cache in mm/slab.c???  

I'll try.


Thanks!

-- 
Martin K. Petersen	Silicon Graphics, Inc.
mkp@sgi.com		http://www.sgi.com/
