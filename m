From: Grant Grundler <iod00d@hp.com>
Date: Mon, 07 Mar 2005 23:36:56 +0000
Subject: Re: PCI Express
Message-Id: <20050307233656.GB2164@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 07, 2005 at 03:11:46PM -0800, Jesse Barnes wrote:
> So the MSIs are programmed to point at the processor SAPIC block?  I think 
> that'll work for us on Altix, but if they're pointed at an external Intel (or 
> compatible) interrupt controller, we'll have to write new code for Altix.

Assuming your "Processor Interrupt Block" (IIRC) is at 0xfee00000
it should just work.

grant
