From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 08 Apr 2004 21:58:40 +0000
Subject: RE: HUGETLB commit handling.
Message-Id: <01EF044AAEE12F4BAAD955CB75064943014B92FA@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15037082.1081445730@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <15037082.1081445730@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Ray Bryant <raybry@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Andy Whitcroft <> wrote on Thursday, April 08, 2004 9:36 AM:

> We have been looking at the HUGETLB page commit issue (offlist) and
> are close a final merged patch.  However, our testing seems to have
> thrown up an inconsistency in interface which we are not sure whether
> to fix or not.   
> 
> With normal shm segments we commit the pages we will need at shmget()
> time. 
> The real pages being allocated on demand.  With hugetlb pages we
> currently do not manage commit, but allocate them on map, shmat() in
> this case.  When we add commit handling it would seem most
> appropriate to commit the pages in shmget() as for small page
> mappings.  However, this might seem to change the semantics slightly,
> in that if there is insufficient hugepages available then the failure
> would come at shmget() and not shmat() time.      
> 
> I would contend this is the right thing to do, as it makes the
> semantics of hugepages match that of the existing small pages.  We
> are looking for a consensus as this might be construed as a semantic
> change.   
> 

IMO, doing this accounting check at shmget time seems reasonable as it
aligns the accouting semantics of normal and hugepages.


> Thoughts.
> 
> -apw
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
> in the body of a message to majordomo@vger.kernel.org More majordomo
> info at  http://vger.kernel.org/majordomo-info.html  

