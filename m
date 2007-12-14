From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Dec 2007 18:19:58 +0000
Subject: RE: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating memory
Message-Id: <1FE6DD409037234FAB833C420AA843EC1A4949@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net> <1FE6DD409037234FAB833C420AA843EC1A3F5B@orsmsx424.amr.corp.intel.com> <7575980D7C4188408E8BDB171DA164B73A875EC00C@G3W1111.americas.hpqcorp.net>
In-Reply-To: <7575980D7C4188408E8BDB171DA164B73A875EC00C@G3W1111.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "de Dinechin, Christophe (Integrity VM)" <christophe.de-dinechin@hp.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Picco, Robert W." <robert.picco@hp.com>

> As you can see, the global purge rates can be pretty respectable
> under this kind of load. I chose -j50 to generate enough processes
> to stress my own system, you may need more with 4G. Check with
> xosview or similar that the buffer cache fills up memory but
> is kept relatively small by user-space memory pressure (at
> around 5-10% for my own testing).

My 4G of memory was indeed the problem ... in two ways:
  1) I didn't install "Everything" on this machine.  So the
     'find /usr -type f | xargs cat' was only juggling with
     just over 2G of files, which all fit in the page cache!
  2) I'd assumed you had used -j50 because you were running
     on some humungous superdome system with that many cpus.
     I was only using -j16 ... which probably fit into the
     remaining available memory.

So I moved the 'find' to /home (which has >7G of files), increased
the -j factor, and just to make really sure ran a little program
that did a malloc() & mlock() of 2G of memory.

I've been running for about 20 minutes and already see just over half
a million cases where your patch avoided flush_tlb_all() (at the
moment it is managing to do so in every case).

Do you know what the call sequence looks like for the few cases
where your patch doesn't manage to avoid (you mentioned just 170
times out of several million in the patch submission)?

-Tony

