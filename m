From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 08 Nov 2003 07:10:29 +0000
Subject: Re: Problem with accessing page tables
Message-Id: <marc-linux-ia64-106827544306970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106826502101883@msgid-missing>
In-Reply-To: <marc-linux-ia64-106826502101883@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 8 Nov 2003 09:46:38 +0530, "Ameya Mitragotri" <ameya.mitragotri@wipro.com> said:

  >>> pmd = pmd_offset(pgd, address); <<<

  Ameya> One of the checks below fails because the call pmd_offset gives pmd 
  Ameya> With value o.

That means the PTE directory hasn't been allocated yet.  Perfectly
normal for memory that hasn't been accessed yet.

	--david
