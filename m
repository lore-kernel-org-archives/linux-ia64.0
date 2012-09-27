From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 27 Sep 2012 19:37:07 +0000
Subject: Re: [PATCH] ia64/xen: fix return value check in xencomm_vtop()
Message-Id: <CA+8MBb+hG9A0vOqc3ZGQX1XULiJ_pLF=twFFz=zJnQEVo8Q=sQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAPgLHd_Z-4j0KNuwy=i0PgoyB+Q3dHCmdey58cadeoqJbnbc4w@mail.gmail.com>
In-Reply-To: <CAPgLHd_Z-4j0KNuwy=i0PgoyB+Q3dHCmdey58cadeoqJbnbc4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 20, 2012 at 9:30 PM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> In case of error, the function follow_page() returns ERR_PTR()
> or NULL pointer. The NULL test in the error handling should be
> replaced with IS_ERR_OR_NULL().

I added a:

#include <linux/err.h>

so that the definition of IS_ERR_OR_NULL() became visible
to xencomm.c and applied.

Thanks

-Tony
