From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Mar 2005 19:31:42 +0000
Subject: RE: cpu_to_node_map on UP systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F030BC187@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> In 2.6.11, cpu_to_node_map has moved from numa.c to smpboot.c.  Since
>> smpboot.c isn't built on non-SMP systems, this causes 
>non-smp builds to
>> fail to link in various places.
>> 
>> I don't know what the right answer is here - resurrect numa.c maybe?
>We do not seem to have a problem on our Autobuild with CONFIG_SMP=n
>http://www.gelato.unsw.edu.au/kerncomp/
>
>Just tested latest bk ChangeSet@1.2028, 2005-03-08 
>16:26:54-08:00, gregkh@suse.de
>tiger_defconfig
>CONFIG_SMP=n
>
>plus removal of some unwanted drivers builds OK

Yes, tiger builds ok with SMP=n (if you pull from the linux-ia64-test-2.6.12
you'll also gets Bjorn's fix to iosapic so the the resulting kernel will
boot, rather than hang).

There are still problems with building the generic kernel with SMP=n

-Tony
