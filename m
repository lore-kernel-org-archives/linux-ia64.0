From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 29 Sep 2003 17:43:28 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106485841224706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> I did some hacking over the weekend. VHPT allocation can be done
> from boot processor in function do_boot_cpu() before waking up
> secondary CPUs.  Allocation can be easily made numa friendly by
> calling alloc_pages_node (didn't bother to do that for now).

I was thinking of the hot-plug CPU case, where the allocation has to be done on the newly added CPU anyway.

	-Arun

