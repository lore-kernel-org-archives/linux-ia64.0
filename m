From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Jan 2016 21:36:15 +0000
Subject: RE: [PATCH v2 1/2] ia64: split off early_ioremap() declarations into asm/early_ioremap.h
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39FAD443@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452604966-9905-1-git-send-email-ard.biesheuvel@linaro.org>
 <3908561D78D1C84285E8C5FCA982C28F39FAC179@ORSMSX114.amr.corp.intel.com>
 <20160113103454.GD25458@arm.com>
In-Reply-To: <20160113103454.GD25458@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux@roeck-us.net" <linux@roeck-us.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>

> The arm trees have already been pulled, so the breakage is in mainline.
>
> I think it makes the most sense to fix this either via the ia64 or the
> efi tree, but I'll queue something at -rc1 if it's still not resolved by
> then.

I put the two patches in the ia64 tree and sent a pull request to Linus.

-Tony
