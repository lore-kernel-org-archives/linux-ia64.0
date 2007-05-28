From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 28 May 2007 02:55:45 +0000
Subject: Re: [patch 4/5] ia64: fail mmaps that span areas with incompatible attributes
Message-Id: <87fy5hfyha.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211622.05198.bjorn.helgaas@hp.com>
In-Reply-To: <200703211622.05198.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Bjorn> Example memory map (from HP sx1000 with VGA enabled): 0x00000 -
Bjorn> 0x9FFFF supports only WB (cacheable) access 0xA0000 - 0xBFFFF
Bjorn> supports only UC (uncacheable) access 0xC0000 - 0xFFFFF
Bjorn> supports only WB (cacheable) access

Bjorn> Some versions of X map the entire 0x00000-0xFFFFF area at once.
Bjorn> With the example above, this mmap must fail because there's no
Bjorn> memory attribute that's safe for the entire area.

Peter> This patch breaks X on a ZX2000.

Except that there is a fix in the latest X source.

Sorry to bother you all.

PeterC
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
