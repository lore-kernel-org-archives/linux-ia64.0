From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 03 May 2006 07:49:03 +0000
Subject: Re: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <20060503074903.GB4798@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com> <4t153d$t4bok@azsmga001.ch.intel.com>
In-Reply-To: <4t153d$t4bok@azsmga001.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Tue, May 02, 2006 at 10:30:07AM -0700, Chen, Kenneth W wrote:
> Boot time option to the rescue!  I have a patch that does just like that.

Being relatively inexperienced, all this dynamic patching (SMP, page
table, this) scares me in that what is executing diverges from what
appears to be in source code, making difficult things even more
difficult to debug.  Is there consensus that a long term goal should
be that short and long formats should be dynamically selectable?

-i
