From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 12 Mar 2003 18:24:11 +0000
Subject: Re: [Linux-ia64] limiting dentries on Linux
Message-Id: <marc-linux-ia64-105590709806066@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Mario" = Mario Smarduch <cms063@email.mot.com> writes:

Mario> I apologize in advance for floating a general Linux question on
Mario> IA-64 group.

Mario> What can be used to limit space allocated for dentries?  For
Mario> example catting non-existing files eats up 30M of memory.

Actually that just goes into the buffer/page caches and will be
released again once someone tries to allocate the memory back using
the appropriate kmalloc() flags, ie. anything but GFP_ATOMIC.

Mario> What group is more relevant to these types of questions.

Possibly linux-kernel, however I doubt you will find much support for
limiting the buffer/page caches.

Cheers,
Jes

