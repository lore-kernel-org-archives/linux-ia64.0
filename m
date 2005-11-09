From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 09 Nov 2005 00:46:21 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <516F50407E01324991DD6D07B0531AD57E7EE4@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On 11/8/05, Gerald Pfeifer <gp@suse.de> wrote:
> 
> > OSVs and ISVs, on the other hand, usually prefer to only 
> test and harden
> > and qualify/certify a single kernel (which is why Dan's 
> approach to Xen/ia64
> > looks quite appealing).
> 
> That's a completely bogus argument though.  Perhaps the ISV is stupid
> enough not to realize what happens when you boot with pgsizedK but
> it certainly doesn't avoid combinatorial explosion (e.g., programs
> that have 16KB page size hardcoded still may fail...).
> 
>   --david

Not completely bogus.  Flexibility always leads to combinatorial
explosion, yet OSVs still support a wide variety of devices,
filesystems, GUIs, etc.  Exposing the ability to more easily
change pagesize is just one more degree of flexibility.  Why
restrict it to "must rebuild kernel"?  And in that case, why not
restrict it to 4K pages only and remove the flexibility from
the ia64 kernel entirely?  (after all, programs that have 4KB page
size hardcoded may fail on ia64 because a small group of kernel
designers decided that 16KB is a better default than 4KB :-)

So, the question becomes who should bear the burden of pagesize
flexibility?  Why should kernel designers decide this (rather
than pass the buck upstream as CPU designers have :-)?

My two cents,
Dan
