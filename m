From: Christoph Hellwig <hch@lst.de>
Date: Tue, 16 Jan 2018 08:28:27 +0000
Subject: Re: consolidate swiotlb dma_map implementations
Message-Id: <20180116082827.GA9211@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de> <20180116075338.GB12693@infradead.org> <76e47666-3de1-68cc-07ad-003491d26ef9@gmail.com>
In-Reply-To: <76e47666-3de1-68cc-07ad-003491d26ef9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: christian.koenig@amd.com
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Christoph Hellwig <hch@infradead.org>, Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Tue, Jan 16, 2018 at 09:22:52AM +0100, Christian K=F6nig wrote:
> Hi Konrad,
>
> can you send the first patch to Linus for inclusion in 4.15 if you haven'=
t=20
> already done so?

It's in the 4.16 queue with a cc to stable.  I guess we're ok with
a duplicate commit if we have to.
