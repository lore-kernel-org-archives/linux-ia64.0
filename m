From: Jes Sorensen <jes@sgi.com>
Date: Mon, 13 Feb 2006 10:53:59 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <43F06547.5050701@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> Jes,
>>I wonder if that isn't mostly bugs on the driver authors side?
>>SA_INTERRUPT was really introduced to handle UART interrupts, whereas
>>I think  all the other drivers you mention ought to be able to handle
>>it correctly.
> 
> Who would know for sure wether interrupt masking is really needed 
> on those drivers?

Hi Stephane,

I would start with the driver maintainers and maybe CC the subsystem
list, like linux-scsi.

I know the qla2xxx driver is very similar to the qla1280 driver which
I maintain, and that no longer uses SA_INTERRUPT. I am guessing the
qla2xxx should be able to do so as well, but check with
andrew.vasquez@qlogic.com

Cheers,
Jes
