From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 22 Feb 2005 19:35:38 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <1109100938.25666.44.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	 <20050222020309.4289504c.akpm@osdl.org> <yq0ekf8lksf.fsf@jaguar.mkp.net>
	 <20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
	 <20050222112513.4162860d.akpm@osdl.org>
In-Reply-To: <20050222112513.4162860d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Matthew Wilcox <matthew@wil.cx>, jes@wildopensource.com, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

I was talking with Nigel Cunningham about doing something a little
different from the classic page flag bits when the number of users is
restricted and performance isn't ultra-critical.  Would something like
this work for you, instead of using a real page->flags bit for
PG_cached?

http://marc.theaimsgroup.com/?l=linux-kernel&m0878103926956&w=2

BTW, they're planning on using two of those dynamic flags for software
suspend, and I'll probably use at least another two in the memory
hotplug code.  

-- Dave

