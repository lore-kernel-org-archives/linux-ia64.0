From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Sep 2001 17:09:03 +0000
Subject: Re: [Linux-ia64] Proc num on an MP plateform
Message-Id: <marc-linux-ia64-105590698805118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 04 Sep 2001 15:01:28 +0200, gerard <gerard@mylos.grenoble.hp.com> said:

  Gerard> Hi I am working on a MP system and I need to know on which
  Gerard> proc num I am running, is there a macro/function call to do
  Gerard> this?(kernel mode).

Depends on what number you want.  If you want the SAPIC id,
ia64_get_lid() is the way to go.  If you just want a unique number,
you can use smp_processor_id().  If you want a number in the range
from 0..smp_num_cpus-1, you can use cpu_number_map(smp_processor_id()).

	--david

