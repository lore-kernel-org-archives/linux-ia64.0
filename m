From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 30 Oct 2001 19:32:05 +0000
Subject: Re: [Linux-ia64] Re: Lion problems with 2.4.13...
Message-Id: <marc-linux-ia64-105590698805417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805415@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 30 Oct 2001 08:30:22 -0600, "Robert K Gjertsen" <gjertsen@us.ibm.com> said:

  Rob> On an entirely different note, I see that flush_tlb_all is
  Rob> exported by the Linux kernel. I've rolled my own functions for
  Rob> flush_tlb_page and flush_tlb_range for our filesystem, but it
  Rob> would be nice if these were also exported by the kernel (I see
  Rob> there is a ptcg lock being used in this code although I think
  Rob> I'm OK not using this on pages that we are fiddling with).  How
  Rob> do I go about seeing if flush_tlb_range could also be exported
  Rob> in the ia64 Linux code stream?

I don't have a problem with exporting flush_tlb_range.  I just added
it to ia64_ksyms.c.

	--david

