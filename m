From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Sep 2006 17:25:47 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <Pine.LNX.4.64.0609121024290.11188@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Sep 2006, Arjan van de Ven wrote:

> > ZONE_DMA is usually used for ISA DMA devices. Typically modern hardware
> > does not have any of these anymore. 
> 
> in the x86 / x86-64 world that statement is not correct ;(

It is true for a large range of hardware. My x86 x64 systems do not need 
the DMA zone and I have been running them for awhile in this mode. Some 
drivers are not available as a result of not having ZONE_DMA.

