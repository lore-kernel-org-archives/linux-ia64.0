From: Grant Grundler <iod00d@hp.com>
Date: Tue, 26 Oct 2004 18:05:46 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <20041026180546.GG2728@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 26, 2004 at 10:55:52AM -0700, Grant Grundler wrote:
> How can a device driver guarantee all in-flight DMA has completed
> before unmapping control data?
> (ie buffers allocated with pci_alloc_consistent()).

nevermind...linus just answered that question.

grant
