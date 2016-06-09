From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Jun 2016 18:26:57 +0000
Subject: RE: [PREEMPT-RT] [PATCH] ia64: salinfo: use a waitqueue instead a sema down/up combo
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A1338E7@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <275e729f-10a6-fdf2-3dfe-d19de4f5b8f0@linutronix.de>
In-Reply-To: <275e729f-10a6-fdf2-3dfe-d19de4f5b8f0@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Do you have ia64 h/w to test this - or do you need me to try it out to
>> make sure the reality matches the expected behavior?
> 
> no ia64 here.

Well it builds and boots. But I realized that to really test it I need to generate
some errors so that salinfo will report them.  I dug into
Documentation/ia64/err_inject.txt and built the kernel driver (lots of warnings
because it didn't get cleaned up when "u64" changed from unsigned long to
unsigned long long), and the user tool.  But it doesn't seem to actually be
injecting anything ... or I'm using it wrong ... it's been ten years since it was added,
most likely on a machine that I no longer have, maybe the PAL on my remaining
machine doesn't do all it says it can for injection?

Summary: The patch is probably fine, but I don't know how to be sure about that :-(

-Tony
