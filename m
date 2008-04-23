From: Jes Sorensen <jes@sgi.com>
Date: Wed, 23 Apr 2008 14:03:58 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <480F41CE.3000803@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
>> I'd rather have PARAVIRT_NR_IRQ set from Kconfig if possible given that
>> all of these are constants anyway. If we cannot do that, then it would
>> be better to do the #if FOO_NR_IRQ > PARAVIRT_NR_IRQ in the various
>> header files for Xen/KVM/lguest so we don't get the clutter in the main
>> makefile.
> 
> Unfotunately Kconfig doesn't support arithmetic comparison.
> So do you want something like the followings?

IMHO, that would be better.

Cheers,
Jes
