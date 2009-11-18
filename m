From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Nov 2009 18:56:19 +0000
Subject: RE: [PATCH 03/16] IA64: use ACCESS_ONCE for rlimits
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E38E71DD@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B040A03.2020508@gmail.com>
 <1258555922-2064-3-git-send-email-jslaby@novell.com>
In-Reply-To: <1258555922-2064-3-git-send-email-jslaby@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@novell.com>, "jirislaby@gmail.com" <jirislaby@gmail.com>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "marcin.slusarz@gmail.com" <marcin.slusarz@gmail.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, James Morris <jmorris@namei.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Make sure compiler won't do weird things with limits. E.g. fetching
> them twice may return 2 different values after writable limits are
> implemented.

-	if (size > task->signal->rlim[RLIMIT_MEMLOCK].rlim_cur)
+	if (size > ACCESS_ONCE(task->signal->rlim[RLIMIT_MEMLOCK].rlim_cur))

I don't see how this helps.  If someone else is changing limits while
we are looking at them, then there is a race.  We either get the old
or the new value.  Using ACCESS_ONCE (which on ia64 forces a "volatile"
access, which will make the compiler generate "ld.acq" rather than a
plain "ld") won't make any difference to this race.

Please explain what issue you see with the current code.

-Tony

