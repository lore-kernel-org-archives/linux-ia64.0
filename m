From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 06:22:37 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106429908824468@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Sep 2003 20:36:29 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> Denied.  Dave, please explain.

Why should I have anything to explain? :-)

The fact that ia64 is doing a printk for an unaligned kernel
load or store is what you should be asking questions about :)

It's one thing if ia64 keeps track of unaligned accesses as
a counter statistic, but emitting a printk for everyone is
pretty anti-social.

Unaligned accesses in the kernel are perfectly normal, and are
absolutely going to happen in various kinds of networking setups.
