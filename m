From: Dave Jones <davej@redhat.com>
Date: Mon, 27 Oct 2003 11:58:47 +0000
Subject: Re: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106725598006548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 27, 2003 at 10:52:59AM +0100, Pavel Machek wrote:

 > > It isn't on some CPUs.  Early athlons go bang when you prefetch
 > > past the end of RAM into unmapped memory for eg.
 > 
 > Well, broken HW :-(

There's a lot of it out there. If we didn't try to work around
some of it, we'd end up running on less < 10% of machines out there 8-)

> but andi's patch should fix up for that.

Different bug.

		Dave

-- 
 Dave Jones     http://www.codemonkey.org.uk
