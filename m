From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 18:45:04 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434395610139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 14:29:25 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Tue, Sep 23, 2003 at 11:21:35AM -0700, Luck, Tony wrote:
> > Looking at a couple of ia64 build servers here I see zero unaligned
> > access messages in the logs.
> 
> ip options can still be an odd number of bytes.  Having itanic spew bogus 
> log messages is just plain wrong (yet another hardware issue pushed off on 
> software for no significant gain).

Also, some TCP implementations sometimes don't align the timestamp
options in the headers as well.

Also, as I mentioned, try IP over appletalk.

Unaligned accesses are perfectly normal, _especially_ in the kernel.
This is an axiom of the kernel networking decided a long time ago, and
printing out a silly message when it happens doesn't make that any
less true.
