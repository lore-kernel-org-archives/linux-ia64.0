From: Ray Bryant <raybry@sgi.com>
Date: Thu, 08 Apr 2004 17:23:00 +0000
Subject: Re: HUGETLB commit handling.
Message-Id: <40758A74.3040107@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1IKJu-Zn-29@gated-at.bofh.it> <m3u0zuwgbf.fsf@averell.firstfloor.org>
In-Reply-To: <m3u0zuwgbf.fsf@averell.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: Andy Whitcroft <apw@shadowen.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Andi,

Yes, that is the plan we are heading for.  However, to make things simpler and 
follow the "subnit a patch that does one thing" rule, we will likely do two 
patches, one to add hugetlb commit handling, and a second one to add lazy 
allocation for i386 and IA64.

The other problem we are wrestling with is how to do the ia386 and ia64 lazy 
allocation code without breaking the architectures that haven't yet switched 
to lazy allocation.  There will probbaly be some

#define ARCH_USES_HUGETLB_PREFAULT

nonsense added to deal with the latter, if needed.

Then, further down the road, we'd like to get the common code across 
architectures moved up from arch/mm to mm.

Andi Kleen wrote:
> Andy Whitcroft <apw@shadowen.org> writes:
> 
> 
>>We have been looking at the HUGETLB page commit issue (offlist) and are
>>close a final merged patch.  However, our testing seems to have thrown up
> 
> 
> This includes lazy allocation for i386 and IA64, right?
> 
> If yes, I'm waiting for your final patch then to remerge the NUMA
> policy code into it (currently NUMA API contains a dumb version of lazy
> allocation for i386 without any prereservation)
> 
> 
>>I would contend this is the right thing to do, as it makes the semantics of
>>hugepages match that of the existing small pages.  We are looking for a
>>consensus as this might be construed as a semantic change.
> 
> 
> I think it's more clean to do it at shmget() time too, so it's probably the
> right thing to do.
> 
> -Andi
> 
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

