From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 15 Jul 2003 20:50:33 +0000
Subject: Re: kernel update (relative to 2.4.21)
Message-Id: <marc-linux-ia64-105830234011997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105716647121510@msgid-missing>
In-Reply-To: <marc-linux-ia64-105716647121510@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday 06 July 2003 10:49 pm, Keith Owens wrote:
> On Wed, 2 Jul 2003 11:08:36 -0600, 
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> >    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.21-ia64-030702.diff.gz
> 
> Make the define for VM_HUGETLB_PAGES the same as 2.5.  Using 14
> conflicts with XFS on 2.4.
> 
> Index: 21.7/include/linux/sysctl.h
> --- 21.7/include/linux/sysctl.h Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/e/b/38_sysctl.h 1.1.5.2.1.1.3.17 644)
> +++ 21.7(w)/include/linux/sysctl.h Mon, 07 Jul 2003 14:46:36 +1000 kaos (linux-2.4/e/b/38_sysctl.h 1.1.5.2.1.1.3.17 644)
> @@ -144,7 +144,7 @@ enum
>  	VM_MAX_MAP_COUNT,	/* int: Maximum number of active map areas */
>  	VM_MIN_READAHEAD,    /* Min file readahead */
>  	VM_MAX_READAHEAD,    /* Max file readahead */
> -	VM_HUGETLB_PAGES	/* Number of available huge pages */
> +	VM_HUGETLB_PAGES,	/* int: Number of available Huge Pages */
>  };

I applied this for 2.4.  Thanks!

