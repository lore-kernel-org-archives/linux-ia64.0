From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 30 Sep 2003 18:25:36 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106494670312945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Darren Williams wrote:
> Hi Arun
> 
> These are useful suggestions and we will need a solution that covers all
> possible scenarios for the page table walker, I have just begun looking
> at the Ia64 code and so my responses may be slow until I get my head 
> around it. One question I do have is that if we are initialising vhpt
> in do_boot_cpu() are we only talking about SMP machines here, what 
> about UNI processor machines?

Yes, do_boot_cpu() doesn't work on UP. I'm still looking into allocating the VHPT on secondary CPUs rather than the boot CPU.

	-Arun

