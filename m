From: Karim Yaghmour <karim@opersys.com>
Date: Fri, 02 Jul 2004 00:53:35 +0000
Subject: Re: [PATCH] IA64 audit support
Message-Id: <40E4B20F.8010503@opersys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406301556.i5UFuGg8009251@redrum.boston.redhat.com> <20040701124644.5e301ca0.akpm@osdl.org>
In-Reply-To: <20040701124644.5e301ca0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Martuccelli <peterm@redhat.com>, faith@redhat.com, davidm@hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ray.lanza@hp.com, Thomas Zanussi <trz@us.ibm.com>, Richard J Moore <richardj_moore@uk.ibm.com>, Robert Wisniewski <bob@watson.ibm.com>, Michel Dagenais <michel.dagenais@polymtl.ca>


Here's what I was trying to say:

Andrew Morton wrote:
> It's nice and simple.

I, and quite a few other folks, have been trying to get the Linux Trace Toolkit
in the kernel for the past 5 years and the code being added is almost identical
to what the audit patch adds, yet we've always got reponses such "this is
bloated" and Linus told us that he didn't see the use of this kind of stuff.

Have we simply not figured out the secret handshake?

I'd really like to have some advice here since I believe we have tried every
trick in the book: posting the patches for review, asking kernel developers for
input, porting the patches to multiple architectures, modulirizing the system,
etc.

Thanks,

Karim
-- 
Author, Speaker, Developer, Consultant
Pushing Embedded and Real-Time Linux Systems Beyond the Limits
http://www.opersys.com || karim@opersys.com || 1-866-677-4546

