From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Mon, 29 Sep 2003 23:48:51 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106487935616561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Arun

These are useful suggestions and we will need a solution that covers all
possible scenarios for the page table walker, I have just begun looking
at the Ia64 code and so my responses may be slow until I get my head 
around it. One question I do have is that if we are initialising vhpt
in do_boot_cpu() are we only talking about SMP machines here, what 
about UNI processor machines?

Darren

On Mon, 29 Sep 2003, Arun Sharma wrote:

> Chen, Kenneth W wrote:
> >I did some hacking over the weekend. VHPT allocation can be done
> >from boot processor in function do_boot_cpu() before waking up
> >secondary CPUs.  Allocation can be easily made numa friendly by
> >calling alloc_pages_node (didn't bother to do that for now).
> 
> I was thinking of the hot-plug CPU case, where the allocation has to be 
> done on the newly added CPU anyway.
> 
> 	-Arun
--------------------------------------------------
Darren Williams <dsw@gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
