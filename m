From: Ray Bryant <raybry@sgi.com>
Date: Fri, 16 Apr 2004 19:05:13 +0000
Subject: Re: hugetlb demand paging patch part [2/3]
Message-Id: <40802E69.7040506@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040416032725.GG12735@zax> <200404160413.i3G4DcF13729@unix-os.sc.intel.com> <20040416044917.GB26707@zax>
In-Reply-To: <20040416044917.GB26707@zax>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, 'Andy Whitcroft' <apw@shadowen.org>, 'Andrew Morton' <akpm@osdl.org>

David,

Is there a big user demand for copy-on-write support for hugetlb pages?
I can understand the rationale for making hugetlb pages behave more like user 
pages, and fixing the problem that hugetlb pages are shared across fork via 
MAP_SHARE semantics regardless of whether the user requests MAP_PRIVATE or 
not, but it just doesn't strike me as something that anyone who uses hugetlb 
pages would actually want.

Of course, YRMV (your requirements may vary).  :-)

'David Gibson' wrote:
> 
> Well, I'm attempting to understand the hugepage code across all the
> archs, so that I can try to implement copy-on-write with a minimum of
> arch specific gunk.  Simplifying and consolidating the existing code
> across archs would be a helpful first step, if possible.
> 

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

