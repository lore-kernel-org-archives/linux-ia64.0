From: Will Deacon <will.deacon@arm.com>
Date: Wed, 13 Jan 2016 10:34:55 +0000
Subject: Re: [PATCH v2 1/2] ia64: split off early_ioremap() declarations into asm/early_ioremap.h
Message-Id: <20160113103454.GD25458@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452604966-9905-1-git-send-email-ard.biesheuvel@linaro.org>
 <3908561D78D1C84285E8C5FCA982C28F39FAC179@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FAC179@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux@roeck-us.net" <linux@roeck-us.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>

On Tue, Jan 12, 2016 at 09:33:46PM +0000, Luck, Tony wrote:
> > So create a <asm/early_ioremap.h> for ia64, and move the existing
> > definitions into it.
> 
> These look OK.
> 
> Acked-by: Tony Luck <toy.luck@intel.com>

s/toy/tony/ ;)

> Can you put them into the same tree where the pending breakage is sitting?
> Then I don't have to worry about coordinating pull requests from the ia64
> tree.

The arm trees have already been pulled, so the breakage is in mainline.

I think it makes the most sense to fix this either via the ia64 or the
efi tree, but I'll queue something at -rc1 if it's still not resolved by
then.

Will
