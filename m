From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 06 Jul 2007 17:32:29 +0000
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
 <468B3EAA.9070905@yahoo.com.au> <20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
 <468C51A7.3070505@yahoo.com.au> <20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
 <468C634D.9050306@yahoo.com.au> <20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com

I am a bit worried about the performance impact of all this flushing? What 
is the worst case scenario here?

