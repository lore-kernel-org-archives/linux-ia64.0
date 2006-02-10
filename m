From: Jes Sorensen <jes@sgi.com>
Date: Fri, 10 Feb 2006 13:54:18 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <yq0lkwj2ub9.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> Jack, Tony, Suposing I move up the PERFMON_VECTOR to 0xf1,
Stephane> it will be in the top priority class (15) with the following
Stephane> vectors:

Hi Stephane,

I admit I don't know much about how this works, but would it be
possible to move IA64_MCA_RENDEZ_VECTOR and IA64_TIMER_VECTOR to the
0xdX group? I looked quickly at a 64-way box internally and it only
had stuff assigned up to irq 70 (70 decimal that is) even with quit a
lot of storage attached.

Cheers,
Jes
