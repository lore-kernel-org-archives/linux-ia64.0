From: Keith Owens <kaos@sgi.com>
Date: Sat, 15 Jan 2005 23:10:20 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <32732.1105830620@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 15 Jan 2005 16:49:06 -0600 (CST), 
Russ Anderson <rja@sgi.com> wrote:
>The MCA recovery driver saves addresses memory errors
>in an array.  The array has 32 entries.  The effect is 
>that after 32 recoveries, the driver stops recovering.
>
>This patch removes the page_isolate array.  Since the array
>was only used to see if the page is already marked reserved,
>check the reserved bit instead of the array.

lkcd dumps kernel pages marked reserved, so lkcd will try to process
isolated pages.  We will eventually need to add a new page flag to mark
faulty pages.

