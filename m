From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 17:27:35 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106433941803375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 07:59:11 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> The printk() is rate-controlled and doesn't happen for every unaligned
> access.  It's average cost can be made as low as we want to, by adjusting
> the rate.

But if the event is normal, you shouldn't be logging it as if
it weren't.

Anyone who tries to use IP over appletalk or certain protocols
over PPP are going to see your silly messages.

As I understand it, you even do this stupid printk for user apps
as well, that makes it more than rediculious.  I'd be surprised
if anyone can find any useful kernel messages on an ia64 system
in the dmesg output with all the unaligned access crap there.

