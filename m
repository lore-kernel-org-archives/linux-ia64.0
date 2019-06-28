From: Christoph Hellwig <hch@lst.de>
Date: Fri, 28 Jun 2019 06:26:19 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190628062619.GA27873@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Btw, as a workaround you could try to disable CONFIG_NUMA in
your .config - as far as I can tell the rx2800 i2 is not actually
a NUMA system.
