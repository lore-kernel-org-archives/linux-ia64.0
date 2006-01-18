From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 18 Jan 2006 14:11:47 +0000
Subject: Re: [ia64-technical] Re: First Montecito Reference Manual is now available
Message-Id: <20060118141146.GA25456@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 19, 2006 at 12:14:53AM +1100, Matthew Chapman wrote:
> 
> It seems to me that, at least at the L2TLB level, the "untagged" model
> could be implemented as an alternative at minimal cost;  e.g. OR the
> control bit into the tag.

Having thought it through, it may not be quite that simple, because of
RR prevalidation.  I'd guess that perhaps on Montecito the Active (RR
match) bit is set on both sets of entries to avoid revalidation on
thread switch?  And you sure don't want the set of mappings merged if
the two threads have different RRs!

In principle I still like the idea of an untagged mode, however...
especially since Itanium is targetted at HPC, and such workloads tend
to have overlap in working sets.  Just my 2c :)

Matt

