From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 18 Jan 2003 01:53:04 +0000
Subject: Re: [Linux-ia64] [Patch] Fix in process.c
Message-Id: <marc-linux-ia64-105590709805722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This one I REALLY don't like:

>>>>> On Fri, 17 Jan 2003 17:43:44 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> - extern char ia64_ret_from_clone;
  Suresh> + extern void  ia64_ret_from_clone(void);

  Suresh> - child_stack->b0 = (unsigned long) &ia64_ret_from_clone;
  Suresh> + child_stack->b0 = ((unsigned long *) &ia64_ret_from_clone)[0];

Why materialize a function pointer for ABSOLUTELY no reason?
Furthermore, &FUNC can be used as a static initializer, whereas
((long*)&FUNC)[0] cannot.

	--david

