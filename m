From: Jack Steiner <steiner@sgi.com>
Date: Sun, 22 Feb 2004 23:08:21 +0000
Subject: Re: HUGEPAGE SIZE a boottime option
Message-Id: <20040222230821.GA32726@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 19, 2004 at 08:00:04PM -0800, Chen, Kenneth W wrote:
> It is not functionally complete though.  alloc_fresh_huge_page(), hugetlb_free_pgtables(), and update_and_free_page has #define constant that indirectly from HPAGE_SHIFT.
> 
> You might checked already, text replication works in this case?
> 

(I posted this earlier. However, our mail server has been messed up & I dont think
the mail got thru. Excuse the duplicate if the other mail ever makes it....)



The patch passes preliminary testing.

I dont see any issues with #define constants indirectly using HPAGE_SHIFT. HPAGE_SHIFT
is now defined as:
        #define HPAGE_SHIFT hpage_shift
and
        extern int hpage_shift;         
        int hpage_shift=HPAGE_SHIFT_DEFAULT;


Indirect references should work ok.


> I have more comments, will post later ...
> 
> - Ken
> 
> 
> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Jack Steiner
> Sent: Thursday, February 19, 2004 5:08 PM
> To: linux-ia64@vger.kernel.org
> Subject: HUGEPAGE SIZE a boottime option
> 
> 
> Here is a preliminary version of a patch that makes the size of
> HUGEPAGES a boottime option. Only ia64-specific files are changed (except
> for the Documentation file).
> 
> We have a number of customers using large pages. Unfortunately, 
> the "optimum" size of a large page is application & configuration
> dependent. Rather that having each customer recompile to specify their
> own HUGEPAGESIZE, this patch make the size a boottime option.
> 
> 
> Does this patch look reasonable? If so, I will incorporate feedback,
> finish testing it, update it to 2.6.3 & resubmit.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


