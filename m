From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Sat, 17 Apr 2004 12:05:40 +0000
Subject: Re: hugetlb demand paging patch part [2/3]
Message-Id: <20040417120540.GC32444@zax>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040416032725.GG12735@zax> <200404160413.i3G4DcF13729@unix-os.sc.intel.com> <20040416044917.GB26707@zax> <40802E69.7040506@sgi.com>
In-Reply-To: <40802E69.7040506@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, 'Andy Whitcroft' <apw@shadowen.org>, 'Andrew Morton' <akpm@osdl.org>

On Fri, Apr 16, 2004 at 02:05:13PM -0500, Ray Bryant wrote:
> David,
> 
> Is there a big user demand for copy-on-write support for hugetlb pages?
> I can understand the rationale for making hugetlb pages behave more like 
> user pages, and fixing the problem that hugetlb pages are shared across 
> fork via MAP_SHARE semantics regardless of whether the user requests 
> MAP_PRIVATE or not, but it just doesn't strike me as something that anyone 
> who uses hugetlb pages would actually want.

My main interest in it is as a prerequisite for various methods of
"automatically" using hugepages for programs where it is difficult to
manually code them to use hugetlbfs.  In particular, think HPC
monsters written in FORTRAN.  e.g. automatically putting suitable
aligned anonymous mmap()s in hugepages under some circumstances (I
can't say I like that idea much), using an LD_PRELOAD to put
malloc()ated memory into hugepages, or using a hacked ELF loader to
put the BSS section (again, think FORTRAN) into hugepages (actually
easier and less ugly than it sounds).

In any of these cases having the memory have different semantics
(MAP_SHARED) to normal anonymous memory would clearly be a Bad Thing.

> Of course, YRMV (your requirements may vary).  :-)
> 
> 'David Gibson' wrote:
> >
> >Well, I'm attempting to understand the hugepage code across all the
> >archs, so that I can try to implement copy-on-write with a minimum of
> >arch specific gunk.  Simplifying and consolidating the existing code
> >across archs would be a helpful first step, if possible.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
