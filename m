From: Grant Grundler <iod00d@hp.com>
Date: Mon, 07 Mar 2005 16:48:13 +0000
Subject: Re: PCI Express
Message-Id: <20050307164813.GD749@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 04, 2005 at 05:42:08PM -0600, Colin Ngam wrote:
> Is MSI/MSIX support available for ia64?

Yes

> Are PCIE devices supported in ia64?

I'm having trouble with the word "supported".
You have a PCI-E Bridge and firmware that can talk to it
hooked up to an ia64 box?

Anyway, linux has some PCI-E support in the generic PCI code.

> A pointer to any documentations with regards to PCIE and ia64 will
> be very much appreciated.

I don't think anything ia64 or linux specific exists.

grant
