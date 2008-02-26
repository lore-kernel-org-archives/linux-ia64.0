From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 26 Feb 2008 08:29:17 +0000
Subject: Re: 2.6.24 new perfmon kernel code base + libpfm + pfmon finally
Message-Id: <20080226082916.GA9857@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470802250900g1eea7a26m1900c4d8ed621dfd@mail.gmail.com> <84144f020802251113m2cede5bbx9044ec1fc6d11f0c@mail.gmail.com> <7c86c4470802251500mafec0dl535591971258de69@mail.gmail.com>
In-Reply-To: <7c86c4470802251500mafec0dl535591971258de69@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stephane eranian <eranian@googlemail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>


* stephane eranian <eranian@googlemail.com> wrote:

> I have done that in the past. I will do this again. But if you look at 
> the patch as it is released, you will see that it is very large. Not 
> that easy to split for LKML review.

If you want a feature merged upstream it is in your basic interest to 
keep it in a tidy, cleanly split up series of patches, with no 
development history in the patches - and frequently post those patches 
to lkml. (it also makes sense tocount the number of times you've posted 
them and make that visible in the postings: so the first series should 
be titled "perform2, v1", the second one "perfmon2, v2" - that way when 
people see "perform2, v25" they'll get a rough picture of the maturity 
of the patchset)

	Ingo
