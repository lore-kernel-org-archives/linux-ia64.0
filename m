From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 03 Sep 2010 15:50:53 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTikZRiQ5jCpgp42LxtXb_S52sSUy7KP_=vZ3z4Tf@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<201009031104.38433.ptesarik@suse.cz>
	<201009031635.25093.ptesarik@suse.cz>
	<201009031652.56476.ptesarik@suse.cz>
In-Reply-To: <201009031652.56476.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Sep 3, 2010 at 7:52 AM, Petr Tesarik <ptesarik@suse.cz> wrote:
> Anyway, if a global TLB flush is necessary to trigger the bug, it would also
> explain why we couldn't reproduce it in user-space.

Perhaps ... I did explore the TLB in one variant of my user mode test I added
a pointer-chasing routine that looked at enough pages to clear out the TLB.
Not quite the same as a flush - but close.  It didn't help at all.

-Tony
