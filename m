From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Jan 2005 21:28:22 +0000
Subject: RE: [patch] Remove limit on MCA recoveries
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02BC57C8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Do not even think about making the array a dynamic size.  MCA events
>can occur even when interrupts are disabled, which means that in an MCA
>you have no idea if any of the kernel structures are in a safe state or
>not.  That in turn means that you cannot extend the array from MCA
>context.  Page flags that indicate bad memory are the best way to go.

Agreed.  If you want to increase the static limit up from 32 to a thousand
or so, as an interim fix until such extra page_flags are agreed upon, then
I'll be ok with that.

-Tony
