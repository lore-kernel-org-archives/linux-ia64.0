From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 22 Jul 2002 12:31:45 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Jul 2002 13:54:36 +0200, 
Andreas Schwab <schwab@suse.de> wrote:
>Why are you explicitly disabling CONFIG_BLK_DEV_LOOP, CONFIG_BLK_DEV_NBD
>and CONFIG_BLK_DEV_RAM?

make xconfig was complaining that those variables appeared elsewhere in
the menu but were not being set in one branch of the menu tree.
Explicitly setting them to "n" removes the xconfig warnings, the
variables were already implicitly set to n.

OTOH, if they should be selected by the user then they need to appear
in both branches of the menu tree.  Looking at the code it could go
either way.  David - was there a reason that these options were omitted
when "$CONFIG_IA64_HP_SIM" = "n"?


