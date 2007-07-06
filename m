From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 06 Jul 2007 21:57:12 +0000
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070707065712.5abbbe43.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<468B3EAA.9070905@yahoo.com.au>
	<20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
	<468C51A7.3070505@yahoo.com.au>
	<20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
	<468C634D.9050306@yahoo.com.au>
	<20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, Mike.stroya@hp.com, y-goto@jp.fujitsu.com, dmosberger@gmail.com, hugh@veritas.com

On Fri, 6 Jul 2007 10:32:29 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> I am a bit worried about the performance impact of all this flushing? What 
> is the worst case scenario here?
> 

IMHO....
When a user set VM_EXEC to their anonymous memory intentionally and
does many page faults.

I myself don't think (file's) page cache flushing is not so heavy work because
PG_arch_1 guarantees that icache flushing occurs just once at the first 
read in the system.

Thanks,
-Kame

