From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Jan 2004 19:06:38 +0000
Subject: Re: [carlos@baldric.uwo.ca: Good news for glibc.]
Message-Id: <16377.46526.239285.352586@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105183349.GC9004@colo.lackof.org>
In-Reply-To: <20040105183349.GC9004@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 5 Jan 2004 11:33:49 -0700, Grant Grundler <grundler@parisc-linux.org> said:

  Grant> glibc profiling?  This was originally posted on
  Grant> debian-hppa/parisc-linux mailing lists.

I'd recommend q-tools.  It will give you a (statistically collected)
call-graph, in addition to the flat profile and is completely
unintrusive (no recompilation etc needed).  See my post for details:

  http://marc.theaimsgroup.com/?l=linux-ia64&m7075994721581

Oh, yeah, I'm slightly biased... ;-)

The one limitation is that it doesn't work well for short-lived
processes.  Also, it works in system-wide mode (collects info for
_all_ processes that happen to run over a given period of time).

If you want per-process profiling, you could use qprof.  It doesn't do
call-graphs (yet) and only works for dynamically linked programs, but
it's very easy to use.  See:

  http://www.hpl.hp.com/research/linux/qprof/

	--david
