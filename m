From: Christoph Hellwig <hch@lst.de>
Date: Mon, 12 Aug 2019 21:52:07 +0000
Subject: Re: fix misc compiler warnings in the ia64 build
Message-Id: <20190812215207.GA21391@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812065524.19959-1-hch@lst.de> <3908561D78D1C84285E8C5FCA982C28F7F41C3D7@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F41C3D7@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 12, 2019 at 09:47:40PM +0000, Luck, Tony wrote:
> > this little series fixes various warnings I see in ia64 builds.
> 
> Applied. Thanks.
> 
> [I assume you are using some up-to-date version of gcc that generates these
>  warnings ... I'm not seeing them, but I'm still using a compiler from the stone
>  age]

This is with the gcc 8.1 x86 to ia64 binary from

http://kernel.mirror.ac.za/tools/crosstool/ that I found recently.  But
at least the fork.c and kprobes.c ones should probably show up with any
supported compiler, the switch ones are fairly new.
