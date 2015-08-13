From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Aug 2015 14:40:36 +0000
Subject: Re: RFC: prepare for struct scatterlist entries without page backing
Message-Id: <20150813144036.GB17375@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de> <55CB3F47.3000902@plexistor.com>
In-Reply-To: <55CB3F47.3000902@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>, torvalds@linux-foundation.org, axboe@kernel.dk, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-nvdimm@ml01.01.org, dhowells@redhat.com, sparclinux@vger.kernel.org, egtvedt@samfundet.no, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, dwmw2@infradead.org, hskinnemoen@gmail.com, linux-xtensa@linux-xtensa.org, grundler@parisc-linux.org, realmz6@gmail.com, alex.williamson@redhat.com, linux-metag@vger.kernel.org, monstr@monstr.eu, linux-parisc@vger.kernel.org, vgupta@synopsys.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-media@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Aug 12, 2015 at 03:42:47PM +0300, Boaz Harrosh wrote:
> The support I have suggested and submitted for zone-less sections.
> (In my add_persistent_memory() patchset)
>
> Would work perfectly well and transparent for all such multimedia cases.
> (All hacks removed). In fact I have loaded pmem (with-pages) on a VRAM
> a few times and it is great easy fun. (I wanted to experiment with cached
> memory over a pcie)

And everyone agree that it was both buggy and incomplete.

Dan has done a respin of the page backed nvdimm work with most of
these comments addressed.

I have to say I hate both pfn-based I/O [1] and page backed nvdimms with
passion, so we're looking into the lesser evil with an open mind.

[1] not the SGL part posted here, which I think is quite sane.  The bio
    side is much worse, though.
