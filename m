From: Keith Owens <kaos@sgi.com>
Date: Tue, 24 Jan 2006 01:42:54 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <7901.1138066974@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant (on Mon, 23 Jan 2006 19:23:50 -0600 (CST)) wrote:
>An even better solution might be to have a hook in the main scheduler
>which sets a "task has migrated" flag in the IA64 thread_info.flags and
>add that flag to the IA64_HAS_EXTRA_STATE() macro.  ia64_load_extra()
>and a machvec can then do the heavy lifting.

The problem with setting arch specific flags in mailine code is the
need to use #ifdef or to define dummy funcions for all architectures.
Apart from that, the idea works for me.  You can pinch the
TIF_SIGDELAYED bit, which I just removed.

