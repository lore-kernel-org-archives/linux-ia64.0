From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 20 Feb 2010 09:31:29 +0000
Subject: Re: [PATCH] Remove COMPAT_IA32 support from ia64.
Message-Id: <87ocjkmexa.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b706604317715a28@agluck-desktop.sc.intel.com>
In-Reply-To: <4b706604317715a28@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> This has been broken since May 2008 when Al Viro killed altroot support.
> Since nobody has complained, it would appear that there are no users of
> this code (A plausible theory since the main OSVs that support ia64 prefer
> to use the IA32-EL software emulation).
>
> Signed-off-by: Tony Luck <tony.luck@intel.com>

Reading old email ... one should note that some of that code 
lives on in the x86-64 32bit emulation. I copied some code 
(not all, other was written from scratch or from other archs)
from ia64 when I did that.

R.I.P.

-And

-- 
ak@linux.intel.com -- Speaking for myself only.
