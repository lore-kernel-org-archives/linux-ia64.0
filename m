From: Robin Holt <holt@sgi.com>
Date: Thu, 22 Jan 2004 09:52:06 +0000
Subject: Re: [2.6.1] eepro100 Taints kernel warning:
Message-Id: <20040122095206.GB27408@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040122024556.GA399@cse.unsw.EDU.AU>
In-Reply-To: <20040122024556.GA399@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 22, 2004 at 01:45:56PM +1100, Darren Williams wrote:
> When loading the eepro100 driver module I get the 
> following warning:
> 
> eepro100: no version for "per_cpu__local_per_cpu_offset" found: kernel tainted.

Simple answer is CONFIG_SMP is not set.  Try setting CONFIG_SMP
an rebuilding.

I will put together a quick patch to move these EXPORT_SYMBOL
declarations to the right place.

Robin
