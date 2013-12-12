From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 12 Dec 2013 00:25:36 +0000
Subject: Re: [PATCH] ia64/xen: Remove Xen support for ia64
Message-Id: <CA+8MBbKRfV6K4GhhGrNQt4okQZgkV=gR7xw=NH6-VLMoX_--GA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1386269247-32401-1-git-send-email-boris.ostrovsky@oracle.com>
In-Reply-To: <1386269247-32401-1-git-send-email-boris.ostrovsky@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, xen-devel@lists.xenproject.org

On Thu, Dec 5, 2013 at 10:47 AM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
> ia64 has not been supported by Xen since 4.2 so it's time to drop
> Xen/ia64 from Linux as well.
>
> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> ---
>
> This is only compile-tested.

Boot tested on a couple of different ia64 machines with no surprises.

Will apply - thanks.

-Tony
