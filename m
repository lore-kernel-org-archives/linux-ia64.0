From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 19 Nov 2009 02:28:16 +0000
Subject: Re: [PATCH 03/16] IA64: use ACCESS_ONCE for rlimits
Message-Id: <20091119022816.GA27729@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B040A03.2020508@gmail.com>
 <1258555922-2064-3-git-send-email-jslaby@novell.com>
 <57C9024A16AD2D4C97DC78E552063EA3E38E71DD@orsmsx505.amr.corp.intel.com>
 <alpine.LFD.2.00.0911181138120.2261@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0911181138120.2261@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jiri Slaby <jslaby@novell.com>, "jirislaby@gmail.com" <jirislaby@gmail.com>, "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "marcin.slusarz@gmail.com" <marcin.slusarz@gmail.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, James Morris <jmorris@namei.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> So the rule is: if you access unlocked values, you use ACCESS_ONCE(). 
> You don't say "but it can't matter". Because you simply don't know.

Most of the time we are being lax about it, especially when it's some 
global value we are accessing, which can only be changed as a sysadmin 
via a sysctl or so.

[ For example we access pid_max in kernel/pid.c, outside of any lock and 
  without ACCESS_ONCE() - but that particular case is not a big deal 
  because changes to pid_max via a sysctl are so rare and are 
  privileged, and because the effects of any race there are benign. ]

But this patch series is about setrlimit, which makes the per task 
rlimit value pretty SMP-volatile (a parallel, unprivileged setrlimit can 
race with usage of the value elsewhere) - and the rlimits have security 
relevance as well so some extra care in accessing them outside of locks 
is prudent IMO.

	Ingo
