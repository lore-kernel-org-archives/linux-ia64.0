From: Martin Pool <mbp@samba.org>
Date: Fri, 16 May 2003 04:44:09 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 15 May 2003, Stephane Eranian <eranian@hpl.hp.com> wrote:

> Yes, distcc is really nice. I have been using it for a month or so
> for my kernel compiles using a cluster of Itanium 2 machines. What
> I like is that it is really easy to setup. The danger with the
> approach is that you can easily overload your local (master) host.

It can work well to use -l as well as -j, to put an upper limit on the
load on the master host.  If you have 2 local CPUs and 8 altogether
then perhaps.

  make -l4 -j10

That ought to make concurrency ramp down as it gets into the linking
phase. 

I ought to add that to the manual/faq.

> As for kernel compiles for 2.5, there are a lot of ld steps
> which are still all done on the master node.  Besides that you
> can really feel the speed difference. I need to take a look at ccache
> now that you mention it.
> 
> Very cool. 

Thanks, I'm glad you like it.

-- 
Martin 

