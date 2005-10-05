From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Oct 2005 21:54:37 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0495CAB6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>It was suggested to me that this might be of interest outside the LSB,
>and that I should forward it more widely...

Running under strace, I see you write 2048 bytes at a time until you
see EAGAIN.  Then you read 4096 bytes to empty the pipe a little.

Then you try to write 4120 bytes (more than you just emptied).

Is that what you are trying to do?

Do you expect a partial write, rather than the EAGAIN?

-Tony
