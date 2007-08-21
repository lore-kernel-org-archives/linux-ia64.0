From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 21 Aug 2007 01:59:08 +0000
Subject: Re: Enable early console for Ski simulator
Message-Id: <87wsvpk5qr.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
In-Reply-To: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@sgi.com> writes:

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:
Peter> When using Ski to debug early startup, it's a bit of a pain not
Peter> to have printk.

Peter> This patch agains 2.6.23-rc? enables the simulated console very
Peter> early.  It may be worth conditionalising on the command
Peter> line... but this is enough for now.

Jes> Hi Peter,

Jes> Really ugly with extern references in brackets like that - how
Jes> about sticking the thing in a header file instead?

Yes you're right.  And looking at the patch, the wrong version got
sent to Tony... (you need to disable the console from being registered
twice or Bad Things Happen (TM))

Patch series follows...

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
