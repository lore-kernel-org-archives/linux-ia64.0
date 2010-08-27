From: Hedi Berriche <hedi@sgi.com>
Date: Fri, 27 Aug 2010 14:52:31 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <20100827145231.GZ18967@zorg.emea.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201008271609.16099.ptesarik@suse.cz> <20100827143135.GY18967@zorg.emea.sgi.com> <201008271640.49542.ptesarik@suse.cz>
In-Reply-To: <201008271640.49542.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Fri, Aug 27, 2010 at 15:40 Petr Tesarik wrote:
| On Friday 27 of August 2010 16:31:35 Hedi Berriche wrote:
|
| > That said, I'm letting my already over 36 hours run carry on chewing CPU
| > time, and see if it will eventually trip the same problem seen with 4-byte
| > ticket locks.
| 
| Hm, this doesn't sound like a viable approach. Since the siglock gets 
| initialized to 0 when a new process is started, it may never actually wrap 
| around.
| 
| I would rather attach a SystemTap probe somewhere during process fork and add 
| a bias to the siglock. That should work fine. Let me knock up the SystemTap 
| script...

That would be nice. Ta!

Cheers,
Hedi.
-- 
Hedi Berriche
Global Product Support
http://www.sgi.com/support
