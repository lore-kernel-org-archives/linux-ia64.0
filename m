From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 May 2007 23:19:11 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0705301537450.1529@schroedinger.engr.sgi.com>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>


> `.exit.text' referenced in section `.init.text' of drivers/built-in.o: 
> defined in discarded section `.exit.text' of drivers/built-in.o


This one is a fatal error ... the code is trying to call a function
that has been marked __exit in a driver that has been built-in, instead
of as a module.  Since a builtin driver can never be unloaded, the kernel
has thrown away all the __exit routines (at link time).

The error message appears less than helpful in tracking down which
routine in which driver is the problem though.

-Tony
