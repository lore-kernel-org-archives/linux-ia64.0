From: Grant Grundler <grundler@cup.hp.com>
Date: Wed, 29 May 2002 19:29:00 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905615@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
> Also, what did you decide to do with the scatter-gather list changes
> (member `address' no longer exists)?   The changes to sb_iommu.c are
> non-trivial, because it looks as if the address field was
> overloaded...

Peter,
I promised David I would resolve that. I wrote the original code
for parisc-linux and Alex Williamson ported that to HP ZX1 chipset.

My excuses are I don't muck with bk, don't have a 2.5
tree lying around, and have been fighting 2.4-related fires
that relate to HP shipping a revenue generating product.

If someone has a tarball of the current to-linus tree I could d/l,
I could look at this sooner.

apologies,
grant

