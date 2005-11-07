From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 Nov 2005 19:10:39 +0000
Subject: RE: [Patch 2.6.14] Extend notify_die() hooks for IA64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04E3F60F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5844.1130898771@kao2.melbourne.sgi.com>
In-Reply-To: <5844.1130898771@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	struct die_args *args = (struct die_args *)data;
> 	switch(val) {
> 	case DIE_BREAK:
>-		if (pre_kprobes_handler(args))
>-			return NOTIFY_STOP;
>+		/* err is break number from ia64_bad_break() */
>+		if (data->err = 0x80200 || data->err = 0x80300)

I just tried merging this patch into Linus latest (which has
some other changes to kprobes.c from Anath).  Maybe I flubbed
the manual merge, but I'm getting compile errors from the
"data->err" dereference.  It looks like this really should read
"args->err" (twice in this line, and once more a few lines
further down).

-Tony
