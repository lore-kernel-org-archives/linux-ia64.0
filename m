From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 12 Jul 2016 12:19:07 +0000
Subject: Re: [PATCH v5 00/44] dma-mapping: Use unsigned long for dma_attrs
Message-Id: <5784E03B.6060000@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467275019-30789-1-git-send-email-k.kozlowski@samsung.com>
 <20160712121625.GP23520@phenom.ffwll.local>
In-Reply-To: <20160712121625.GP23520@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-pci@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, hch@infradead.org, linux-rockchip@lists.infradead.org, nouveau@lists.freedesktop.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, linux-xtensa@linux-xtensa.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-arm-msm@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mediatek@lists.infradead.org, linux-omap@vger.kernel.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 07/12/2016 02:16 PM, Daniel Vetter wrote:
> On Thu, Jun 30, 2016 at 10:23:39AM +0200, Krzysztof Kozlowski wrote:
>> Hi,
>>
>>
>> This is fifth approach for replacing struct dma_attrs with unsigned
>> long.
>>
>> The main patch (1/44) doing the change is split into many subpatches
>> for easier review (2-42).  They should be squashed together when
>> applying.
> 
> For all the drm driver patches:
> 
> Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> 
> Should I pull these in through drm-misc, or do you prefer to merge them
> through a special topic branch (with everything else) instead on your own?
> -Daniel

Thanks. I saw today that Andrew Morton applied the patchset so I think
he will handle it.

Best regards,
Krzysztof

