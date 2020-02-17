From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Mon, 17 Feb 2020 13:16:38 +0000
Subject: Re: [PATCH] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <alpine.DEB.2.21.2002171409410.14734@felia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200217081558.10266-1-lukas.bulwahn@gmail.com> <CADxRZqwGBi=4A224mG0cPgONdNitnvi3LFD_KQckxdYSXzgBGg@mail.gmail.com> <alpine.DEB.2.21.2002170950390.11007@felia> <20200217130828.GB26781@lst.de>
In-Reply-To: <20200217130828.GB26781@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Anatoly Pugachev <matorola@gmail.com>, Pat Gefre <pfg@sgi.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>



On Mon, 17 Feb 2020, Christoph Hellwig wrote:

> On Mon, Feb 17, 2020 at 10:09:45AM +0100, Lukas Bulwahn wrote:
> > The description is about situations on very outdated kernel versions, so 
> > the whole page needs a general update.
> 
> While the file doesn't seem all that useful, I think removing or updating
> it should probably be a separate patch.
> 
Okay, I will send a v2 where I keep the documentation and I will add a
maintainers entry for Documentation/ia64/ to IA64 (Itanium) PLATFORM.

Lukas
