From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 19:10:44 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575913199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 12:17:21 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> Look, this may be difficult for you to understand, but different
> people find different policies useful.

You, sure.  But you are not the only user of the ia64 port just
as I am not the only user of the sparc64 port and if sparc64 generated
diagnostic messages not useful to people other than me I'd have to
quiet them by default.

All I'm suggesting is provide a way to control the kernel unaligned
accesses message and default it to off.
