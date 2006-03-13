From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Mar 2006 20:05:00 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05EFA650@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
>Hmm, I think another alternative is to rip out all the itc insertion
>code and let the hardware page walker do the "dirty" job.  Because it
>is known and architected to be atomic-read-and-insert and is also
>known to honor ptc.g while atomic-read-and-insert is in-flight (i.e.,
>won't insert tlb entry).

Can we get some perf. numbers ... this will take each dirty fault twice
(though the second should be fast if VHPT does it's job).  This might
be slower than putting in the srlz.d that Zoltan wants.

-Tony
