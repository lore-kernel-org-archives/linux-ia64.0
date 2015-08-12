From: Julian Calaby <julian.calaby@gmail.com>
Date: Wed, 12 Aug 2015 23:37:37 +0000
Subject: Re: RFC: prepare for struct scatterlist entries without page backing
Message-Id: <CAGRGNgUKkaPnyvn30DXyNpdiXQzS6J=1+mQ3ick8C8=bhx_RHA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de> <55CB3F47.3000902@plexistor.com>
In-Reply-To: <55CB3F47.3000902@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, axboe@kernel.dk, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-nvdimm@ml01.01.org, David Howells <dhowells@redhat.com>, sparclinux <sparclinux@vger.kernel.org>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, David Woodhouse <dwmw2@infradead.org>, =?UTF-8?Q?H=C3=A5vard_Skinnemoen?= <hskinnemoen@gmail.com>, linux-xtensa@linux-xtensa.org, grundler@parisc-linux.org, realmz6@gmail.com, alex.williamson@redhat.com, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, vgupta@synopsys.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org

Hi,

On Wed, Aug 12, 2015 at 10:42 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 08/12/2015 10:05 AM, Christoph Hellwig wrote:
>> It turns out most DMA mapping implementation can handle SGLs without
>> page structures with some fairly simple mechanical work.  Most of it
>> is just about consistently using sg_phys.  For implementations that
>> need to flush caches we need a new helper that skips these cache
>> flushes if a entry doesn't have a kernel virtual address.
>>
>> However the ccio (parisc) and sba_iommu (parisc & ia64) IOMMUs seem
>> to be operate mostly on virtual addresses.  It's a fairly odd concept
>> that I don't fully grasp, so I'll need some help with those if we want
>> to bring this forward.
>>
>> Additional this series skips ARM entirely for now.  The reason is
>> that most arm implementations of the .map_sg operation just iterate
>> over all entries and call ->map_page for it, which means we'd need
>> to convert those to a ->map_pfn similar to Dan's previous approach.
>>
>
[snip]
>
> It is a bit of work but is worth while, and accelerating tremendously
> lots of workloads. Not like this abomination which only branches
> things more and more, and making things fatter and slower.

As a random guy reading a big bunch of patches on code I know almost
nothing about, parts of this comment really resonated with me:
overall, we seem to be adding a lot of if statements to code that
appears to be in a hot path.

I.e. ~90% of this patch set seems to be just mechanically dropping
BUG_ON()s and converting open coded stuff to use accessor functions
(which should be macros or get inlined, right?) - and the remaining
bit is not flushing if we don't have a physical page somewhere.

Would it make sense to split this patch set into a few bits: one to
drop all the useless BUG_ON()s, one to convert all the open coded
stuff to accessor functions, then another to do the actual page-less
sg stuff?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
