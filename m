From: Dave Jones <davej@redhat.com>
Date: Sun, 26 Oct 2003 14:51:56 +0000
Subject: Re: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106717995315153@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Oct 25, 2003 at 10:10:10PM +0200, Pavel Machek wrote:

 > > This patch was accepted into 2.5.55, attributed to "davej@uk".
 > Dave Jones?n

Yep.

 > > This code will prefetch from beyond the end of the page table
 > > being cleared ... which is clearly a bad thing if the page table
 > > in question is allocated from the last page of memory (or precedes
 > > a hole on a discontig mem system).
 > Prefetching random addresses should be safe...

It isn't on some CPUs.  Early athlons go bang when you prefetch
past the end of RAM into unmapped memory for eg.

		Dave

-- 
 Dave Jones     http://www.codemonkey.org.uk
