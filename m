From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Nov 2018 16:50:47 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, jdmason@kudzu.us, joro@8bytes.org, David Woodhouse <dwmw2@infradead.org>, m.szyprowski@samsung.com, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Thu, Nov 22, 2018 at 6:03 AM Christoph Hellwig <hch@lst.de> wrote:
>
> The 0 return doesn't work for direct mappings that have ram at address
> zero and a lot of IOMMUs that start allocating bus space from address
> zero, so we can't consolidate on that, but I think we can move everyone
> to all-Fs, which the patch here does.

Hmm. Maybe not limit it to just all ones, but actually use the
(standard, for the kernel) IS_ERR_VALUE()?

That basically reserves the last 4095 values in an unsigned long for
error values.

Then those functions could actually return *what* error they
encountered, using just plain

        return -ENOMEM;

or whatever?

               Linus
