From: "Martin K. Petersen" <mkp@wildopensource.com>
Date: Mon, 18 Oct 2004 18:54:13 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <yq1acujrh62.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net>
	<20041014180427.GA7973@wotan.suse.de> <yq1ekjvrjd6.fsf@wilson.mkp.net>
	<20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041018184210.GI16153@parcelfarce.linux.theplanet.co.uk> (Matthew
 Wilcox's message of "Mon, 18 Oct 2004 19:42:10 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

>>>>> "Matthew" = Matthew Wilcox <matthew@wil.cx> writes:

Matthew> It's probably worth doing this with a static cachep in slab.c
Matthew> and only exposing a get_zeroed_page() / free_zeroed_page()
Matthew> interface, with the latter doing the memset to 0.  

*nod*


Matthew> I disagree with Andi over the dumbness of zeroing the whole
Matthew> page.  That makes it cache-hot, which is what you want from a
Matthew> page you allocate from slab.

Yeah, plus the housekeeping may be more of a hassle than it's worth.

We'll see...

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/
