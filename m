From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 16 Aug 2000 15:45:09 +0000
Subject: Re: [Linux-ia64] Exporting symbol in linux2.4/ia64
Message-Id: <marc-linux-ia64-105590678205337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205335@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205335@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 16 Aug 2000 13:59:27 +0200 (MEST), 
"G\\351raud Krawezik" <gk@scali.no> wrote:
>While working on a driver, I've experienced the following when trying to
>insmod it (i'm using 2.4-test6):
>
>unresolved symbol clear_page
>unresolved symbol softirq_state
>unresolved symbol __ia64_memcpy_toio
>unresolved symbol __free_pages_ok
>
>softirq_state is a 'case to study', but for the three others, it's
>slightly different, as:

softirq_state was moved and renamed in 2.4.0-test6.  See
include/linux/irq_cpustat.h for the new definitions.  You either
compiled your module against old headers or you are trying to insmod an
old module.  2.4.0-test6 also cleaned up the /lib/modules directory
structure but the transition might have left old structure around, try
"rm -rf /lib/modules/2.4.0-test6" and "make modules_install" to get rid
of any old structure.  Also check that you have modutils 2.3.14.


