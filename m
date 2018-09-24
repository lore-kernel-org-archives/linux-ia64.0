From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 24 Sep 2018 17:38:20 +0000
Subject: Re: [REVIEW][PATCH 0/3] signal/ia64: siginfo fixes and cleanups
Message-Id: <20180924173818.GA9522@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <87bm8n2czz.fsf@xmission.com>
In-Reply-To: <87bm8n2czz.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

On Mon, Sep 24, 2018 at 04:20:32PM +0200, Eric W. Biederman wrote:
> 
> It turns out that ia64 is one of the noticable offenders.  Ever since
> ia64 was merged in 2.3.43 it has been generating incorrect siginfo for
> SIGSEGV assocaited with the inability to setup a signal stack frame
> or cleanup a signal stack frame.

I'll blame that on the "previous administration". I didn't start work
on Linux until 2.3.99, and didn't take over as maintainer until 2.6.11 :-)

> I don't think I have made made any mistakes in this coversion but if
> people can look the code over and see if they can spot anything I would
> appreciate it.

I don't see any mistakes either. It builds and boots. Obviously I don't
have a test case for this issue (or it would have been found long ago).

> My intention is to merge this through my siginfo tree.  If you feel it
> should go through your arch tree let me know.   All of the prerequisites
> should have been merged several releases ago.

Sure. Merge away.

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
