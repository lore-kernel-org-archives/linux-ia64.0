From: Ray Bryant <raybry@sgi.com>
Date: Sun, 04 Apr 2004 22:15:33 +0000
Subject: Re: [PATCH] HUGETLB memory commitment
Message-Id: <40708905.2080907@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404040331.i343VSF02496@unix-os.sc.intel.com>
In-Reply-To: <200404040331.i343VSF02496@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andy Whitcroft' <apw@shadowen.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Ken,

If you have user space code that tests this that you can send me I'll use them 
to fix up the reservation and quota code to handle this case as well.

Thanks,

Chen, Kenneth W wrote:
>>>
> 
> 
> This assumes all mmap start from the same file offset. IMO, it's not
> generic enough. This code will only reserve 1 page for the following
> case, but actually there are 4 mapping totaling 4 pages:
> 
> mmap 1 page at file offset 0
> mmap 1 page at file offset HPAGE_SIZE,
> mmap 1 page at file offset HPAGE_SIZE*2,
> mmap 1 page at file offset HPAGE_SIZE*3,
> 
> Oh, this code broke file system quota accounting as well.
> 
> - Ken
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
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

