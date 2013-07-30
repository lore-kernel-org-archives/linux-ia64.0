From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 30 Jul 2013 19:57:49 +0000
Subject: Re: [PATCH 0/4] Make commonly useful UEFI functions common
Message-Id: <CA+8MBb+VzakCg0NAfxTxQ+LipvKhjTL4QaU5Q-vEU=hVZViq_A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, patches@linaro.org

On Tue, Jul 30, 2013 at 9:47 AM, Leif Lindholm <leif.lindholm@linaro.org> wrote:
> IA64 code compile tested only.

Compiled on a bunch of ia64 configurations, Boot tested. But not on machine that
does the PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID thingy.
Code to do the arch specific thing looks ok though.

-Tony
