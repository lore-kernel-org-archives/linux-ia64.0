From: Andi Kleen <ak@muc.de>
Date: Thu, 08 Apr 2004 17:05:40 +0000
Subject: Re: HUGETLB commit handling.
Message-Id: <m3u0zuwgbf.fsf@averell.firstfloor.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1IKJu-Zn-29@gated-at.bofh.it>
In-Reply-To: <1IKJu-Zn-29@gated-at.bofh.it> (Andy Whitcroft's message of
 "Thu, 08 Apr 2004 18:40:12 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Ray Bryant' <raybry@sgi.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Andy Whitcroft <apw@shadowen.org> writes:

> We have been looking at the HUGETLB page commit issue (offlist) and are
> close a final merged patch.  However, our testing seems to have thrown up

This includes lazy allocation for i386 and IA64, right?

If yes, I'm waiting for your final patch then to remerge the NUMA
policy code into it (currently NUMA API contains a dumb version of lazy
allocation for i386 without any prereservation)

> I would contend this is the right thing to do, as it makes the semantics of
> hugepages match that of the existing small pages.  We are looking for a
> consensus as this might be construed as a semantic change.

I think it's more clean to do it at shmget() time too, so it's probably the
right thing to do.

-Andi

