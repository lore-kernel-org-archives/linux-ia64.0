From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Mar 2005 04:45:56 +0000
Subject: Re: Automatically optimizing hand coded assembler
Message-Id: <16954.23812.563464.146911@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7848.1111113418@kao2.melbourne.sgi.com>
In-Reply-To: <7848.1111113418@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 18 Mar 2005 13:36:58 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The code in ia64_syscall_setup has several independent steps
  Keith> to execute.  Interleaving the instructions from each step by
  Keith> hand to avoid empty slots is painful, not to mention error
  Keith> prone.  Are there any tools available for this task?

  Keith> I envisage a tool where the user defines the instructions
  Keith> required for each step separately, including the stop bits
  Keith> needed for ordering within the individual step.  The
  Keith> resources used by each step must be disjoint.  The user also
  Keith> defines sync points, where steps must start, end or join with
  Keith> other steps.  The tool draws the DAG from the sync points
  Keith> then runs down the DAG, picking instructions from each step
  Keith> to best fill the slots.  The output is all the instructions,
  Keith> nicely interleaved to give the minimum number of bundles.

I suggested a project along these lines to a few students a while ago
but unfortunately nothing came out of it.  IIRC, Intel at one point
had a "visual assembler" which was doing something similar, but it was
Windows only and I don't know what became of it.

	--david
