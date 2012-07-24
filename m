From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jul 2012 16:47:50 +0000
Subject: RE: [linus:master 69/70] include/sound/soc.h:790:14: error: expected ':', ',', ';', '}' or '__attrib
Message-Id: <3908561D78D1C84285E8C5FCA982C28F1936F975@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There are lots of weird sound/* build errors and the root cause is the
> below "platform_name" macro name colliding with snd_soc_dai_link.platform_name
>
> Can we just rename the macro to ia64_platform_name?

Sounds like a good idea. Send me a patch and I'll queue it for linux-next.

-Tony
