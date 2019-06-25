From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 25 Jun 2019 11:21:38 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <0f76468f-8648-62d8-68d2-455c74c19328@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/25/19 1:19 PM, Frank Scheiner wrote:
>> Instead.
> 
> Ok, that looks much better now with the second patch:
> ...even after a second reboot for verification. Great!(
> (...)
> I assume this won't affect UMA Itaniums or should I check on one of my
> other Integrities if this change breaks the kernel on them?

Nice! I just assume we won't be able to use the patch "as is" as it would
potentially break other architectures if I'm not mistaken.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
