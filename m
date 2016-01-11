From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Jan 2016 19:54:09 +0000
Subject: RE: [PATCH] efi: add conditional include of asm/early_ioremap.h
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39FA9F4B@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452456249-2974-1-git-send-email-ard.biesheuvel@linaro.org>
 <20160111144004.GD2644@codeblueprint.co.uk>
In-Reply-To: <20160111144004.GD2644-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: "linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org" <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, "Yu, Fenghua" <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

On Sun, 10 Jan, at 09:04:09PM, Ard Biesheuvel wrote:
> The code in efi.c uses early_memremap(), but relies on a transitive
> include rather than including asm/early_ioremap.h directly.
> Unfortunately, this header does not exist on ia64, so it cannot be
> included directly.

I wouldn't be adverse to you making an asm/early_ioremap.h file
for ia64

-Tony
