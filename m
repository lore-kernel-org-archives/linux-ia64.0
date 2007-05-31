From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 31 May 2007 06:12:23 +0000
Subject: Re: BUG: sleeping function called from invalid context at
Message-Id: <20070530231223.bc75f7fb.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com>
	<Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
	<20070530163413.87ecfe18.randy.dunlap@oracle.com>
	<Pine.LNX.4.64.0705301652100.3731@schroedinger.engr.sgi.com>
	<465E0F03.6000103@oracle.com>
	<Pine.LNX.4.64.0705301657530.3832@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705301657530.3832@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Wed, 30 May 2007 17:09:56 -0700 (PDT) Christoph Lameter wrote:

> On Wed, 30 May 2007, Randy Dunlap wrote:
> 
> > OK.  I would write the file to disk and view it with an editor.
> > Then at each occurrence of /exit.text/, see if it's inside an __init
> > function...
> 
> Ahh okay. cscope will do that too.... But all have __exit.

I did a cross-build, but I'm not having any luck finding the problem
either.  FWIW, mine shows up as:

  LD      .tmp_vmlinux1
local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
make[1]: [.tmp_vmlinux1] Error 1 (ignored)
  KSYM    .tmp_kallsyms1.S

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
