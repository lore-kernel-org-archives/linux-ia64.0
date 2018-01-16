From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Date: Tue, 16 Jan 2018 08:52:28 +0000
Subject: Re: consolidate swiotlb dma_map implementations
Message-Id: <485e6f8b-ef22-0792-1acc-3fefe203040c@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
 <20180116075338.GB12693@infradead.org>
 <76e47666-3de1-68cc-07ad-003491d26ef9@gmail.com>
 <20180116082827.GA9211@lst.de>
In-Reply-To: <20180116082827.GA9211@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Christoph Hellwig <hch@infradead.org>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Am 16.01.2018 um 09:28 schrieb Christoph Hellwig:
> On Tue, Jan 16, 2018 at 09:22:52AM +0100, Christian K=C3=B6nig wrote:
>> Hi Konrad,
>>
>> can you send the first patch to Linus for inclusion in 4.15 if you haven=
't
>> already done so?
> It's in the 4.16 queue with a cc to stable.  I guess we're ok with
> a duplicate commit if we have to.

Yeah, while it's only a false positive warning it would be really nice=20
to have in 4.15.

It affects all drivers using TTM in the system and not just the two I'm=20
the maintainer of.

Regards,
Christian.
