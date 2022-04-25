From: Bjorn Helgaas <helgaas@kernel.org>
Date: Mon, 25 Apr 2022 21:16:17 +0000
Subject: Re: [PATCH 0/7] Remove unused SLOW_DOWN_IO
Message-Id: <20220425211617.GA1658400@bhelgaas>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20220422104828.75c726d0@kernel.org>
References: <20220415190817.842864-1-helgaas@kernel.org>
In-Reply-To: <20220415190817.842864-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <kuba@kernel.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Chas Williams <3chas3@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Paul Mackerras <paulus@samba.org>, Matt Turner <mattst88@gmail.com>, Paolo Abeni <pabeni@redhat.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>, Richard Henderson <rth@twiddle.net>

On Fri, Apr 22, 2022 at 10:48:28AM -0700, Jakub Kicinski wrote:
> On Fri, 15 Apr 2022 14:08:10 -0500 Bjorn Helgaas wrote:
> > From: Bjorn Helgaas <bhelgaas@google.com>
> > 
> > Only alpha, ia64, powerpc, and sh define SLOW_DOWN_IO, and there are no
> > actual uses of it.  The few references to it are in situations that are
> > themselves unused.  Remove them all.
> > 
> > It should be safe to apply these independently and in any order.  The only
> > place SLOW_DOWN_IO is used at all is the lmc_var.h definition of DELAY,
> > which is itself never used.
> 
> Hi Bojrn! Would you mind reposting just patches 1 and 3 for networking?
> LMC got removed in net-next (commit a5b116a0fa90 ("net: wan: remove the
> lanmedia (lmc) driver")) so the entire series fails to apply and therefore 
> defeats all of our patch handling scripts :S

Sure, coming up, with reduced cc: list.
