From: Jes Sorensen <jes@linuxcare.com>
Date: Mon, 13 Nov 2000 23:20:43 +0000
Subject: Re: [Linux-ia64] Simple Question Simple Answer
Message-Id: <marc-linux-ia64-105590678205714@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205701@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205701@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Brian" = Brian Boerner <brian_boerner@ntc.adaptec.com> writes:

Brian> Let me begin by saying that I'm not really new to Linux but
Brian> have only been doing Linux development for about a year
Brian> now. I'm looking for a list of differences one must consider
Brian> when trying to write drivers that are portable.

Brian> Correct me if I'm wrong, but the 2.2 code stream for Linux is
Brian> ia32 while the 2.4 code stream is going to support ia64. Is
Brian> there a list of gottchas somewhere that ISVs should watch out
Brian> for? Please forgive me if this is something that has been asked
Brian> a 1000 times, but hey.. I'm new.

That kinda depends on what you are trying to achieve. Are you trying
to write drivers that run under both 2.2 and 2.4 (covering all
applicaple architectures of course: little endian/big endian - 32 vs
64 bit) or just code that will run in 2.4?

There are some API changes which you have to deal with, but a lot of
that can be handled by putting in backwards compatibility macros for
2.2 in your code. I use that trick in the AceNIC Gigabit Ethernet
driver for instance (drivers/net/acenic.[ch]).

Jes

