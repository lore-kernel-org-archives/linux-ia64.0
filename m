From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Fri, 14 Apr 2006 03:12:31 +0000
Subject: Re: [PATCH 8/8] IA64 various hugepage size - Modify kernel document
Message-Id: <20060413201231.24b8ae7e.rdunlap@xenotime.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1144974367.5817.39.camel@linux-znh>
	<1144974667.5817.51.camel@linux-znh>
	<1144974881.5817.59.camel@linux-znh>
	<1144975292.5817.74.camel@linux-znh>
	<1144975523.5817.84.camel@linux-znh>
	<1144975746.5817.94.camel@linux-znh>
	<1144975953.5817.102.camel@linux-znh>
	<1144976261.5817.114.camel@linux-znh>
	<1144976418.5817.122.camel@linux-znh>
In-Reply-To: <1144976418.5817.122.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zou Nan hai <nanhai.zou@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, kenneth.w.chen@intel.com

On 14 Apr 2006 09:00:18 +0800 Zou Nan hai wrote:

> Modify the kernel document about hugetlb
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> diff -Nraup a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> --- a/Documentation/vm/hugetlbpage.txt	2006-03-20 13:53:29.000000000 +0800
> +++ b/Documentation/vm/hugetlbpage.txt	2006-04-12 06:13:50.000000000 +0800
> @@ -68,9 +68,12 @@ If the user applications are going to re
>  call, then it is required that system administrator mount a file system of
>  type hugetlbfs:
>  
> -	mount none /mnt/huge -t hugetlbfs <uid=value> <gid=value> <mode=value>
> +	mount none /mnt/huge -t hugetlbfs -o <uid=value> <gid=value> <mode=value>
>  		 <size=value> <nr_inodes=value>
>  
> +on IA64 there is another mount option page_size=value which could
> +mount a hugetlbfs with given huge page size;
> +

Typos.  How about:
On IA64 there is another mount option (page_size=value) which can be
used to mount a hugetlbfs with the given huge page size.


>  This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
>  /mnt/huge.  Any files created on /mnt/huge uses hugepages.  The uid and gid
>  options sets the owner and group of the root of the file system.  By default



---
~Randy
