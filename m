From: Matt_Domsch@Dell.com
Date: Thu, 05 Dec 2002 16:19:02 +0000
Subject: RE: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805503@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805503@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For those of you who're impatiently waiting for a 2.5.xx update, I put
> a preliminary patch at:

I'm still unable to create include/asm-ia64/offsets.h properly.

include/linux/sched.h has:
union thread_union {
        struct thread_info thread_info;
        unsigned long stack[INIT_THREAD_SIZE/sizeof(long)];
};

(INIT_THREAD_SIZE needs to be number)

include/asm-ia64/thread_info.h has:
#define INIT_THREAD_SIZE                /* tell sched.h not to declare the
thread_union */

(INIT_THREAD_SIZE isn't a number)


Deleting the declaration of INIT_THREAD_SIZE lets it continue and builds
offsets.h.  Is that safe?

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com


