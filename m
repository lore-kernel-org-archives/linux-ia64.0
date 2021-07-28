From: Jens Axboe <axboe@kernel.dk>
Date: Wed, 28 Jul 2021 19:59:41 +0000
Subject: Re: [PATCH] arch: Kconfig: clean up obsolete use of HAVE_IDE
Message-Id: <3c09d6d8-7f83-4f6f-d496-20f5b1b4a7d8@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210728182115.4401-1-lukas.bulwahn@gmail.com>
In-Reply-To: <20210728182115.4401-1-lukas.bulwahn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Christoph Hellwig <hch@lst.de>, Randy Dunlap <rdunlap@infradead.org>
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 7/28/21 12:21 PM, Lukas Bulwahn wrote:
> The arch-specific Kconfig files use HAVE_IDE to indicate if IDE is
> supported.
> 
> As IDE support and the HAVE_IDE config vanishes with commit b7fb14d3ac63
> ("ide: remove the legacy ide driver"), there is no need to mention
> HAVE_IDE in all those arch-specific Kconfig files.
> 
> The issue was identified with ./scripts/checkkconfigsymbols.py.

Thanks, let's queue this for 5.14 to avoid any future conflicts with
it.

-- 
Jens Axboe
