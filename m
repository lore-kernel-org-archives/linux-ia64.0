From: Grant Grundler <iod00d@hp.com>
Date: Thu, 25 Sep 2003 20:29:54 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106452214602650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 20, 2003 at 08:20:25AM +0100, Christoph Hellwig wrote:
> Well, that someone is qlogic.

ah - even better.

> But I don's see why it should go into the ia64 tree.

It shouldn't - should be mainline submittal.

> Once qlogic got the driver in shape it and/or the feral
> driver should go into mainline.

I exchanged email with Matthew Jacob <mjacob@feral.com> in Jan 2003 and
data corruption occurred in < 10 minutes of functional testing.
(Sorry Jes, I remembered wrong - it wasn't a panic).
I could add retesting this driver to my TODO list if someone thinks
it's worthwhile.

feral.com driver stopped being interesting to me becuase the qlogic
drivers have usually  passed functional testing (found very few issues).
I find stylistic "bugs" easier to fix than correctness issues...

hth,
grant
