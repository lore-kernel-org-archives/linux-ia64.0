From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 17 Jan 2005 01:07:46 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <41EB0FE2.6050901@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> The MCA recovery driver saves addresses memory errors
> in an array.  The array has 32 entries.  The effect is 
> that after 32 recoveries, the driver stops recovering.
> 
> This patch removes the page_isolate array.  Since the array
> was only used to see if the page is already marked reserved,
> check the reserved bit instead of the array.

This array is temporary designed for future use.
Similar to what Keith said, the array would be helpful if
something like dump application have no idea to avoid reading
MCA pages.

Roughly say, traditionally there are 2 type of pages:
  1 - not reserved
  2 - reserved
IMHO, there should be additional 3 type:
  3 - MCA reserved, not classified, don't read
  4 - Hard error (e.g. page on broken DIMM)
  5 - Soft error (e.g. having poisoned data)

The MCA recovery driver just does isolation.
What the driver want to do is marking 3 to the MCA pages.

It would better if type 3 pages could be classified into 4 or 5,
and more better if type 5 pages could be recycled into the system.

Thanks,
H.Seto

