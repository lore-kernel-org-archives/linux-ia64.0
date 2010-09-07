From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 07 Sep 2010 17:35:47 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTikdHZY1sOJFCMn8Zaca2rO6MsbXL459LZ4HOJTk@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<AANLkTikZRiQ5jCpgp42LxtXb_S52sSUy7KP_=vZ3z4Tf@mail.gmail.com>
	<201009061647.02345.ptesarik@suse.cz>
	<201009071517.43009.ptesarik@suse.cz>
In-Reply-To: <201009071517.43009.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 7, 2010 at 6:17 AM, Petr Tesarik <ptesarik@suse.cz> wrote:
> Anyway, after applying the following patch, the test case provided by Hedi has
> been running for a few hours already. Now, I'm confident this is a hardware
> bug.

Started up a test with this patch on my 32-way to confirm.

-Tony
