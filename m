From: peterc@gelato.unsw.edu.au
Date: Thu, 08 Feb 2007 08:28:55 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <87zm7pkq7s.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Zou" = Zou Nan hai <nanhai.zou@intel.com> writes:

Zou> Pin ar.kr2 of each CPU, so that smp_processor_id can use it.
Zou> This will save some memory foot-print when smp_procerror_id() is
Zou> called.

Accessing ar.k? takes 12 cycles... it's faster in the kernel to
use current_thread_info()->cpu which if cache hot can be done in two
cycles.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
