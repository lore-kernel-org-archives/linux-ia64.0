From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 25 Jun 2019 06:40:01 +0000
Subject: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Christoph!

On 6/21/19 10:08 PM, Frank Scheiner wrote:
> recent testing of a Debian v4.19.37 kernel showed a problem on my rx2800
> i2 happening during kernel boot:
> (...)
> [1]:
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?idT3cea9accd9804307541cb93d3ed7ec94b07237

Do you have any idea what could be the reason for the issue introduced
by your above commit? James Clarke has guess that it might be GFP_DMA32
which isn't being set properly anymore for the affected machines.

Do you think we could test a kernel which just sets the flag unconditionally
to see whether this is the problem that causes the issues on these machines?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
