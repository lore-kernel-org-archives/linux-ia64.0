From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 19 Mar 2005 00:58:50 +0000
Subject: RE: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F031D6515@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Tony> That reminds me ... someone asked why we don't have the same
>  Tony> test for lfetch a few lines further down in
>  Tony> ia64_do_page_fault() in the "no_context" case (we only test
>  Tony> for speculative access there).
>
>Clearly a bug.  Hopefully, that explains Keith's case as well?

Keith: I put the fix for ia64_do_page_fault() into my test-2.6.12 tree, so
you can try it out ... your memcpy fix is in there too.

-Tony
