From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 07 Dec 2004 02:38:03 +0000
Subject: RE: q-tools v0.2 released
Message-Id: <200412070235.iB72ZNg07055@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410111552.i9BFqiHj020907@napali.hpl.hp.com>
In-Reply-To: <200410111552.i9BFqiHj020907@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Monday, October 11, 2004 8:53 AM
> I'm happy to announce that q-tools v0.2 has been released.  q-tools is
> a collection of Linux performance analysis tools.  In particular, they
> include q-syscollect and q-view, which can be thought of as being more
> powerful than gprof, without its pain (no recompilation needed;
> multi-threaded apps and shared libraries are supported;
> kernel-execution can be profiled; any Itanium 2 PMU event can be
> profiled, etc.).
>

I'm craving for more, is there a q-merge kind of utility out there? i.e.,
merge all the cpu .hist files into one to get an overall system profile.  I
can do that right now by hand (cat cpu*.hist into one file and then generate
corresponding .info file).  I hope someone already had such tool so I don't
have to reinvent the wheel.

- Ken


