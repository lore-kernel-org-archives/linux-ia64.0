From: Robin Holt <holt@sgi.com>
Date: Mon, 22 Nov 2004 12:14:15 +0000
Subject: Re: smp_call_function/flush_tlb_all hang on large memory system
Message-Id: <20041122121415.GA13845@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <267988DEACEC5A4D86D5FCD780313FBB2BFBB4@exch-03.noida.hcltech.com>
In-Reply-To: <267988DEACEC5A4D86D5FCD780313FBB2BFBB4@exch-03.noida.hcltech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Deepak Kumar Gupta, Noida" <dkumar@hcltech.com>
Cc: "'lilbilchow@yahoo.com'" <lilbilchow@yahoo.com>, "'ananth@sgi.com'" <ananth@sgi.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

On Mon, Nov 22, 2004 at 03:15:00PM +0530, Deepak Kumar Gupta, Noida wrote:
> Hi William/Rajagopal
> 
> I saw your posting related to problem on internet. Just curious to ask you
> have you got any solution for that or not.. as i am facing same problem on
> SGI Propack 3 (based on kernel 2.4.18)on 2 CPU IA64 machine..
> 
> If you got any solution for this then pls let me know..
> 
> Any help in this regard is appreciated.
> 
> posting: http://www.cs.helsinki.fi/linux/linux-kernel/2003-11/1153.html
> 

Can you provide the output from an L2 "leds" command?  This will tell us
what the cpus are doing and whether they have interrupts enabled.  Have you
contacted your support people yet?  I did not see an open case for this,
but have no idea how your support person exactly filed it.

Thanks,
Robin Holt
