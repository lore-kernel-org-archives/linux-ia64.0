From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 05 Dec 2002 17:08:22 +0000
Subject: RE: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805505@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 5 Dec 2002 10:19:02 -0600, Matt_Domsch@Dell.com said:

  Matt> I'm still unable to create include/asm-ia64/offsets.h
  Matt> properly.

  Matt> include/linux/sched.h has: union thread_union { struct
  Matt> thread_info thread_info; unsigned long
  Matt> stack[INIT_THREAD_SIZE/sizeof(long)]; };

  Matt> (INIT_THREAD_SIZE needs to be number)

  Matt> include/asm-ia64/thread_info.h has: #define INIT_THREAD_SIZE
  Matt> /* tell sched.h not to declare the thread_union */

  Matt> (INIT_THREAD_SIZE isn't a number)

Something must have gone wrong with applying the ia64 patch.  In sched.h,
it should say:

 #ifndef INIT_THREAD_SIZE

right before the thread_union declaration.

	--david

