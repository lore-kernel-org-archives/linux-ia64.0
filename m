From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 16 Mar 2006 23:37:22 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <adalkvaneq5.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com>
	<20060314134535.72eb7243.akpm@osdl.org>
	<44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de>
	<44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com>
	<4419BD64.5070705@ce.jp.nec.com> <20060316194155.GP13666@sgi.com>
	<20060316232837.GA12408@suse.de>
In-Reply-To: <20060316232837.GA12408@suse.de> (Greg KH's message of "Thu, 16 Mar 2006 15:28:37 -0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@suse.de>
Cc: Mark Maule <maule@sgi.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

    Greg> As msi.c today is pretty platform-specific as is, I don't
    Greg> have a problem with moving the ia64 stuff also into that
    Greg> directory.  Especially as it will help solve issues like
    Greg> this a lot better.

I think we really want to make drivers/pci/msi.c less
platform-specific.  Both powerpc and sparc64 are starting to pay
attention to MSI, so we should really be trying to move things in the
direction of a clean separation of generic MSI handling and
Intel-specific bits.

 - R.
