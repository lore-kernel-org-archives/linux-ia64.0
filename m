From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 23 Sep 2003 18:29:25 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434256308210@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 11:21:35AM -0700, Luck, Tony wrote:
> Looking at a couple of ia64 build servers here I see zero unaligned
> access messages in the logs.

ip options can still be an odd number of bytes.  Having itanic spew bogus 
log messages is just plain wrong (yet another hardware issue pushed off on 
software for no significant gain).

		-ben
-- 
"The software industry today survives only through an unstated agreement 
not to stir things up too much.  We must hope this lawsuit [by SCO] isn't 
the big stirring spoon." -- Ian Lance Taylor, Linux Journal, June 2003
