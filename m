From: "Tony Luck" <tony.luck@intel.com>
Date: Sat, 15 Nov 2008 19:57:29 +0000
Subject: Re: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <12c511ca0811151157u71abfecfn3361885167a2d540@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 14, 2008 at 7:26 PM, David Mosberger-Tang
<dmosberger@gmail.com> wrote:
>  In any case, as I remember, the idea was that the kernel would always
>  execute with PSR.AC=1 to avoid silent performance bugs and just since
>  the kernel should be alignment-clean, anyhow.  The fys-code doesn't
>  turn on PSR.AC, but I believe the heavy-weight syscall path does.  I
>  don't know why head.S turns off PSR.AC.  Seems like a bug to me.

Running base code and interrupt/trap code with different settings of PSR.ac
does sound like a bug ... but the question of what we should set it to deserves
a little more thought.

Perhaps the best option would be for test & development kernels to set
PSR.ac=1 to aid in tracking down any alignment problems in the code.
But production kernels should set PSR.ac=0 so that they don't take the
cost of a trap on unaligned access that the specific model of processor
can handle anyway.  If this is the right path, then it should become a
CONFIG option.

-Tony
