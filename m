From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Jan 2005 20:11:26 +0000
Subject: RE: [PATCH] cleanup swiotlb.c a bit
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A67657@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I find the former more readable.  It lets you know there's something
>coming on the next line.

I too prefer to leave the binary operator trailing on the first line,
scripts/Lindent seems to do this too for the cases that I tried, though
it makes poor choices on which binary operator to leave dangling in a
long expression ... it just makes the first line as long as possible
without going over the 80 char limit ... which often isn't the best
place to split the line.

>> Well, it probably should move outside of the ia64 tree anyhow.  The
>> way x86_64 includes swiotlb.c at the moment is just absolutely gross.
>
>kernel/swiotlb.c would make most sense, I guess?

That would be fine for me ... one less file for me to manage :-)

-Tony
