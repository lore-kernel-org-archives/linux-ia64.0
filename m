From: Ray Bryant <raybry@sgi.com>
Date: Sun, 28 Mar 2004 18:02:02 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <4067131A.7000405@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk> <20040325130433.0a61d7ef.akpm@osdl.org> <41997489.1080257240@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <41997489.1080257240@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, mbligh@aracnet.com

I guess I am missing something entirely here.  I've been off making "allocate on fault" hugetlb 
pages work on 2.4.21 on Altix (that is, after all, the kernel for the production code for Altix at 
the present time -- It's getting close, still working on making fork() work correctly with this, and 
once that is done I will move it to 2.6 and submit a patch.)

As I understood this originally, the suggestion was to reserve hugetlb pages at mmap() or shm_get() 
time so that the user would get an -ENOMEM at that time if there aren't enough hugetlb pages to 
(eventually) satisfy the request, as per the notion that we shouldn't modify the user API due to 
going with allocate on fault instead of hugetlb_prefault().

Since the reservation belongs to the mapped object (file or segment), I've been storing the current 
file/segments's reservation in the file system dependent part of the inode.  That way, it is easily 
accessible when the hugetlbfs file or SysV segment is removed and we can reduce the total number of 
reserved pages by that file's reservation at that time.  This also allows us to handle the 
reservation in the absence of a vma, as per Andy'c comment below.

Admittedly this doesn't alow one to request that hugetlbpages be overcommitted, or to handle 
problems caused to the "normal" page overcommit code due to the presence of hugepages.  But we 
figure that anyone that is actually using hugetlb pages is likely to take over almost all of main 
memory anyway in a single job, so overcommit doesn't make much sense to us.

So, am completely off "in the weeds" on this or does the above seem like an acceptable, and simple,
approach?

Andy Whitcroft wrote:
> --On 25 March 2004 13:04 -0800 Andrew Morton <akpm@osdl.org> wrote:
> 
> 
>>Sorry, but I just don't see why we need all this complexity and generality.
>>
>>If there was any likelihood that there would be additional memory domains
>>in the 2.6 future then OK.  But I don't think there will be.  We simply
>>need some little old patch which fixes this bug.
>>
>>Such as adding a `vma' arg to vm_enough_memory() and vm_unacct_memory() and
>>doing
>>
>>	if (is_vm_hugetlb_page(vma))
>>		return;
>>
>>and
>>
>>-	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
>>+	allowed = (totalram_pages - htlbpagemem << HPAGE_SHIFT) *
>>+			sysctl_overcommit_ratio / 100;
>>
>>in cap_vm_enough_memory().
> 
> 
> That's pretty much what you get if you only apply the first two patches.  Sadly, you can't just pass a vma as you don't always have one when you are making the decision.  For example when a shm segment is being created you need to commit the memory at that point, but its not been attached at all so there is no vma to check.  That's why I went with an abstract domain.  These patches have been tested in isolation and do seem to work.
> 
> The other patches started out wanting to solve a second issue, the generality seemed to come out naturally.  I am not sure how important it is, but when we create a normal shm domain we commit the memory then.  For an hugetlb one we only commit the memory when the region is attached the first time, ie when the pages are cleared and filled.  Also we have no policy control over them.
> 
> In short I guess if we only are trying to fix the overcommit cross over between the normal and hugetlb, then the first two patches should be basically there.
> 
> Let me know what the decision is and I'll steer the ship in that direction.
> 
> -apw
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

