From: Andrew Morton <akpm@osdl.org>
Date: Thu, 25 Mar 2004 21:04:33 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <20040325130433.0a61d7ef.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

Andy Whitcroft <apw@shadowen.org> wrote:
>
> HUGETLB Overcommit Handling
> ---------------------------
> When building mappings the kernel tracks committed but not yet
> allocated pages against available memory and swap preventing memory
> allocation problems later.  The introduction of hugetlb pages has
> has significant ramifications for this accounting as the pages used
> to back them are already removed from the available memory pool.

Sorry, but I just don't see why we need all this complexity and generality.

If there was any likelihood that there would be additional memory domains
in the 2.6 future then OK.  But I don't think there will be.  We simply
need some little old patch which fixes this bug.

Such as adding a `vma' arg to vm_enough_memory() and vm_unacct_memory() and
doing

	if (is_vm_hugetlb_page(vma))
		return;

and

-	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
+	allowed = (totalram_pages - htlbpagemem << HPAGE_SHIFT) *
+			sysctl_overcommit_ratio / 100;

in cap_vm_enough_memory().

