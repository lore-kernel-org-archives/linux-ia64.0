From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 26 Mar 2004 03:39:09 +0000
Subject: Re: [Lse-tech] Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <5310.1080272349@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Fri, 26 Mar 2004 14:28:26 +0530."
             <20040326085826.GA3332@in.ibm.com> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: suparna@in.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, apw@shadowen.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

On Fri, 26 Mar 2004 14:28:26 +0530, 
Suparna Bhattacharya <suparna@in.ibm.com> wrote:
>On Thu, Mar 25, 2004 at 04:22:32PM -0800, Andrew Morton wrote:
>> Keith Owens <kaos@sgi.com> wrote:
>> >
>> > FWIW, lkcd (crash dump) treats hugetlb pages as normal kernel pages and
>> > dumps them, which is pointless and wastes a lot of time.  To avoid
>> > dumping these pages in lkcd, I had to add a PG_hugetlb flag.  lkcd runs
>
>This should already be fixed in recent versions of lkcd. It uses a
>little bit of trickery to avoid an extra page flag -- hugetlb pages are 
>detected as "in use" as well as reserved, unlike other reserved pages 
>which helps identify them.

Are you sure that this works for hugetlb pages that have been
preallocated but not yet mapped?  AFAICT the hugetlb pages start off as
reserved with a zero usecount.

