From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 09 Nov 2000 15:56:23 +0000
Subject: Re: [Linux-ia64] Performance Monitor Internals:
Message-Id: <marc-linux-ia64-105590678205676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Nov 2000 10:40:32 -0500, "Ross Ridge" <ross@sitraka.com> said:

  Ross> I'm also interested in using the performance monitor, but my
  Ross> only concern is if user processes will able to access the
  Ross> performance counters directly with a "mov 1,PMD[r2]"
  Ross> instruction, instead of having to use some sort of kernel
  Ross> service to access the counter.  Essentially, all I'm looking
  Ross> for is a replacement for the IA-32's "RDTSC" instruction in
  Ross> the code I'm porting.

You can use the attached code.

	--david

static __inline__ unsigned long
ia64_get_itc (void)
{
	unsigned long result;

	__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
	while (__builtin_expect ((int) result = -1, 0))
		__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
	return result;
}

