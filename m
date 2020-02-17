From: Anatoly Pugachev <matorola@gmail.com>
Date: Mon, 17 Feb 2020 08:45:17 +0000
Subject: Re: [PATCH] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <CADxRZqwGBi=4A224mG0cPgONdNitnvi3LFD_KQckxdYSXzgBGg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200217081558.10266-1-lukas.bulwahn@gmail.com>
In-Reply-To: <20200217081558.10266-1-lukas.bulwahn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Cc: Pat Gefre <pfg@sgi.com>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Mon, Feb 17, 2020 at 11:16 AM Lukas Bulwahn <lukas.bulwahn@gmail.com> wrote:
>
> Commit 9c860e4cf708 ("tty/serial: remove the ioc3_serial driver") and
> commit a017ef17cfd8 ("tty/serial: remove the ioc4_serial driver") removed
> the ioc{3,4}_serial driver, but missed some files.
>
> Fortunately, ./scripts/get_maintainer.pl --self-test complains:
>
>   warning: no file matches F: drivers/tty/serial/ioc?_serial.c
>
> The driver is gone, so remove the other obsolete files and maintainer
> entry as well.
>
> Signed-off-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
> ---
> Christoph, please ack. Tony, please pick this patch.
> applies cleanly on 5.6-rc2 and next-20200217
> only sanity-grep for filenames and make htmldocs, no compile testing
>
>  Documentation/ia64/index.rst  |   1 -
>  Documentation/ia64/serial.rst | 165 ----------------------------------
>  MAINTAINERS                   |   8 --
>  include/linux/ioc3.h          |  93 -------------------
>  4 files changed, 267 deletions(-)
>  delete mode 100644 Documentation/ia64/serial.rst

Can you please at leat leave in tree serial.rst since it has generic
nature and not describing only ioc3_serial driver? Does ioc3_serial
the only serial driver available under ia64 ? Or can we please not to
loose some docs? Or do we have a more common serial driver description
somewhere which has info on ia64 serial driver/ports ?

Thanks.
