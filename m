From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 17 Jul 2004 06:53:24 +0000
Subject: Re: final [hopefully] timer patches
Message-Id: <16632.52452.93429.751980@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407161057440.29976@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407161057440.29976@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph,

The fsys.S portion of the patch still doesn't apply.  I think that's
because your missing Ken's fix for fsys_gettimeofday() that went in
recently.

Also, it would be good if the common code for fsys_gettimeofday() and
fsys_clock_get() could be factored (into a macro, probably, since you
can't use the standard calling convention without switching to kernel
stacks first).

Thanks,

	--david
