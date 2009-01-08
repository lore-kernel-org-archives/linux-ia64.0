From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jan 2009 22:24:31 +0000
Subject: RE: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CC52122@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Are you changes now confined to ia64 (besides the recordmcount.pl)
> change?  Any changes to the ftrace infrastructure we would like to go
> through tip. This will give it proper testing against all archs before
> pushing it to mainline.
>
> Please send me any patches outside of arch/ia64 that we can pull in.
> This includes the recordmcount.pl patch.

ia64 bits look ok to me.  We may be able to tune some bits to
make them better, but I'd be fine with the current version
going in.

Should I be trying to squeak the ia64 bits into the last few days
of the current merge window ... or are you going to save the
generic bits like the recordmcount.pl changes for 2.6.30?

-Tony

