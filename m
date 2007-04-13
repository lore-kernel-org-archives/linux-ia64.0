From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 13 Apr 2007 16:45:49 +0000
Subject: RE: [KJ][PATCH 02/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <617E1C2C70743745A92448908E030B2A015B4E12@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070413043140.GA9431@arun.site>
References: <20070412203140.GB9353@arun.site>
In-Reply-To: <20070412203140.GB9353@arun.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Milind Arun Choudhary <milindchoudhary@gmail.com>
Cc: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de

> So as ALIGN macro does the same work as ROUNDUP,

Although it is mathematically the same operation, the
semantic associations of the name are important too.
If I have an I/O device that works in blocks of a given
size, I don't think that I'm "aligning" a request to make
it match the capabilities of the device, I think that I'm
"rounding up" to a multiple of the size.

Maybe this is because I started out in mathematics before
discovering that computers were so much fun, or maybe it
is a British-English bias ... I can't tell, but it makes
sense to me to use ROUNDUP in some places, and ALIGN in
others.

I haven't scanned through all usages to see whether existing
usage matches my bias ... but changing them all to use just
one name doesn't feel like the right thing to do.  It makes
some code less clear (to me).

>      is at a common place
>      & is accessible to everyone

If ROUNDUP isn't available everywhere, then it should be. To
avoid code duplication perhaps we should add:

    #define ROUNDUP(size, len) ALIGN((size), (len))

and delete the previous ROUNDUP definition?

-Tony
