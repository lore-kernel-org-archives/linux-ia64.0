From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Feb 2020 13:08:28 +0000
Subject: Re: [PATCH] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <20200217130828.GB26781@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200217081558.10266-1-lukas.bulwahn@gmail.com> <CADxRZqwGBi=4A224mG0cPgONdNitnvi3LFD_KQckxdYSXzgBGg@mail.gmail.com> <alpine.DEB.2.21.2002170950390.11007@felia>
In-Reply-To: <alpine.DEB.2.21.2002170950390.11007@felia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Cc: Anatoly Pugachev <matorola@gmail.com>, Pat Gefre <pfg@sgi.com>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Mon, Feb 17, 2020 at 10:09:45AM +0100, Lukas Bulwahn wrote:
> The description is about situations on very outdated kernel versions, so 
> the whole page needs a general update.

While the file doesn't seem all that useful, I think removing or updating
it should probably be a separate patch.
