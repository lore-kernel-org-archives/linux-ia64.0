From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 Nov 2004 21:31:16 +0000
Subject: RE: [PATCH] top level scheduler domain for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02510DBE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I think the short-term solution is to make the boot-time parameter
>> like Jesse said to control the creation and span size of the
>> node domain and see what is necessary next.
>
>This patch adds a new kernel parameter "nodes_per_domain"
>which specifies how many nodes are included in a node 
>scheduling domain.

Can you add a short write-up for Documentation/kernel-parameters.txt
to explain the effect, and how a user should pick what value to use
(examples would be good ... if SGI want to throw in some
values for small/large Altix boxes, that would be good too).

Is '6' a reasonable default if the parameter is not set?

-Tony
