From: Gerald Pfeifer <gp@suse.de>
Date: Thu, 23 Feb 2006 23:11:16 +0000
Subject: RE: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <Pine.LNX.4.64.0602240006130.30639@yvsfpuvgm.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Feb 2006, Alex Williamson wrote:
> What firmware version do you have on your zx2000?  I saw the same
> problem with my zx2000 running firmware 2.21 and was hacking at a work
> around, when I realized version 2.31 is available on the HP website.

This sounds *very* familiar!  I've been experiencing similar troubles on 
zx6000, until a colleague helped with a firmware update.

In a nutshell:

  SAL 3.1: HP version 2.31 -- this you want

  SAL 3.1: HP version 2.21 -- this you want to upgrade (though it
                              had serviced me well for two years)

> Please check and let us know.

Yes, I can confirm what you've been experiencing.

Gerald
