From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 14 Nov 2007 07:53:06 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <473AA962.6090701@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roland McGrath wrote:
> What's arch_ptrace_resume about?  
> I thought we were agreed on the plan using TIF_RESTORE_RSE.

No, after further discussion we came to the conclusion that introducing
the bit actually saves us only a couple of user-to-kernel/kernel-to-user
copies in do_exit(), but it complicates the kernel exit path, so it's
not really worth it. Shaohua didn't call it arch_ptrace_resume(), but he
added an argument to arch_ptrace_stop(). I was already testing a
different variant of that patch and I'm sorry if it caused confusion. :(

Is there any other advantage in introducing TIF_RESTORE_RSE than saving
some unneeded data copying?

Regards,
Petr Tesarik

> Thanks,
> Roland

