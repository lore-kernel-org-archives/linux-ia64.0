From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 23:32:52 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436077230564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 15:58:29 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> Which is great until the "cleverly written" program is fed a data set
> that pushes into the unaligned case far more frequently than the
> programmer anticipated.

Which is why the people who work on the networking are well
aware of the issues and will make sure the common case never
triggers these unaligned accesses.

People writing protocol stacks _don't_ feed these data unaligned
cases out onto the wire, because like us they want the networking
to go fast.  Why in the world do you think they specify in the
very RFCs that define the protocols that one should use NOP options
in the TCP option area in order to align TCP timestamps on a 32-bit
boundry?

Do you think they say this so people can go ahead and use memmove()'s
and byte loads all over the place anyways?

No, rather, they specify things so that unless you do something
absolutely stupid all the shit is aligned properly.

It is absurdly stupid to do byte loads of TCP and IP header
bits just because one tenth of one hundredths of one percent
of systems have some configuration where word and half-word
loads of these things will be unaligned _AND_ be slow on that
cpu.
