From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 23:35:32 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436105230857@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003 09:04:12 +1000
Ian Wienand <ianw@gelato.unsw.edu.au> wrote:

> Just as a point of interest, as an application programmer I think it's
> the type of thing you want to know about quite loudly.

Sure, and I agree that you should have the choice to see
these messages at the verbosity you desire, and ia64 has
the capability to control things in this way.

What I disagree with is spitting out log messages about such things
happening in the kernel.  Because that is remotely triggerable.  As
Alan mentioned, if I can send packets to your ia64 box I can make it
spew system log messages.

