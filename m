From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 23 Sep 2003 10:40:05 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106431367304136@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David S Miller <davem@redhat.com> writes:

David> On Mon, 22 Sep 2003 20:36:29 -0400 Benjamin LaHaise
David> <bcrl@kvack.org> wrote:

>> Denied.  Dave, please explain.

David> Why should I have anything to explain? :-)

David> The fact that ia64 is doing a printk for an unaligned kernel
David> load or store is what you should be asking questions about :)

How expensive is it to take the trap and do a fix up, compared to
making an aligned copy?  As it involves raising and handling a fault
disassembling the instruction that caused the fault, etc., I'd be
surprised if it's much less than 1000 cycles, even without the printk,
although I haven't measured it yet, and can't find enough info in the
architecture manuals to know what it is.

Even if it's only 500 cycles, you can copy and realign a large packet
in that time. 

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
