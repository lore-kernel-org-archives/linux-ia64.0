From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 25 Jan 2005 21:15:37 +0000
Subject: RE: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <200501252115.j0PLFbg18138@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.59631.914927.689418@napali.hpl.hp.com>
In-Reply-To: <16877.59631.914927.689418@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 12:36:51 -0800, "Luck, Tony" <tony.luck@intel.com> said:
  Tony> I've had reports from Ken Chen and Bjorn Helgaas of illegal instruction
  Tony> traps in the kernel while booting.  Backing out this patch makes the
  Tony> problem go away.

  Tony> Bjorn was using "defconfig".  Not sure what Ken used.  I
  Tony> haven't seen any such problems using tiger_defconfig, nor with
  Tony> defconfig on my tiger.

David Mosberger wrote on Tuesday, January 25, 2005 12:42 PM
> Oh, I should have used TEXT_ALIGN(32) instead of .align 32, since
> .align inside a function was broken for a long time.
>
> Bjorn, Ken, does that fix your problem?


Yes, that fixes my problem.

- Ken


