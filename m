From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Apr 2006 14:34:08 +0000
Subject: RE: [PATCH] eliminate compiler warning for xpc_channel.c
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06223978@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
In-Reply-To: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Did you mean to say "*msg = NULL"?
>
> this is actually an ANSI-permitted idiom for shutting up compiler
> warnings while not actually initialising the variable.

So I learned something new today!

But then this patch is wrong ... it shuts the compiler up
and leaves 4 ways that xpc_allocate_msg() can return without doing
the initialization, so that msg will be used uninitialized.

-Tony
