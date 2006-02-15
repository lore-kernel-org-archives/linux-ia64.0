From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 15 Feb 2006 09:08:41 +0000
Subject: RE: [PATCH] ia64: simplify and fix udelay()
Message-Id: <200602150908.k1F98dg02934@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060214184017.20492.48141.sendpatchset@tomahawk.engr.sgi.com>
References: <20060213183344.21339.33094.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060213183344.21339.33094.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Jes Sorensen <jes@sgi.com>

hawkes@sgi.com wrote on Tuesday, February 14, 2006 10:40 AM
> a preemption and migration to another CPU during the
> while-loop

Off topic from the subject line a bit, but related: how many Altix
SN2 customers in the field turn on CONFIG_PREEMPT? Redhat EL4 doesn't
turn on preempt, SuSE SLES9 and SLES10 beta don't turn it on either.
Is there a real benefit of turning that option on for SN2?

- Ken

