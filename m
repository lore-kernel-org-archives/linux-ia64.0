From: Jes Sorensen <jes@wildopensource.com>
Date: Sun, 05 Oct 2003 16:41:03 +0000
Subject: Re: [PATCH] more dead headers
Message-Id: <marc-linux-ia64-106537214311026@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106467172926098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106467172926098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


FYI

fetchop.h and ioc4.h are for GPL'ed drivers that have already been
published for 2.4 - they just need to be ported to 2.6. We can take
them out now and stick them back in later if you prefer but doing so
seems silly to me.

nag.h is a goner and ifconfig_net.h is history for 2.6 for sure.

Cheers,
Jes
