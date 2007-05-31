From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 31 May 2007 00:09:56 +0000
Subject: Re: BUG: sleeping function called from invalid context at
Message-Id: <Pine.LNX.4.64.0705301657530.3832@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com>
 <Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
 <20070530163413.87ecfe18.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0705301652100.3731@schroedinger.engr.sgi.com>
 <465E0F03.6000103@oracle.com>
In-Reply-To: <465E0F03.6000103@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Wed, 30 May 2007, Randy Dunlap wrote:

> OK.  I would write the file to disk and view it with an editor.
> Then at each occurrence of /exit.text/, see if it's inside an __init
> function...

Ahh okay. cscope will do that too.... But all have __exit.

