From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 01 Jun 2007 04:05:54 +0000
Subject: Re: BUG: sleeping function called from invalid context at
Message-Id: <Pine.LNX.4.64.0705312105280.30098@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01961A60@scsmsx411.amr.corp.intel.com>
 <465F9315.2050207@redhat.com>
In-Reply-To: <465F9315.2050207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Thu, 31 May 2007, Prarit Bhargava wrote:

> I used the sn2_defconfig in the tree :)

That is a static kernel build. Ideal for that kind of bug.

