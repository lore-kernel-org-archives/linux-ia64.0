From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 15 Mar 2006 17:37:15 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B14CB421AD82C944A59ED6C1CA4E068F0D8D9A@scsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Wednesday, March 15, 2006 5:30 AM
> This patch is based on the Christoph's one entitled "Fix race in the
> accessed/dirty bit handlers".
> 
> - It adds the lacking "srlz.d"

It is still not clear whether srlz.d is required or not, right?  Wording
in SDM is vague.  Through experiment, I've verified that itc instruction
observe full instruction latency with respect to memory operation that
immediately follows it. It is pretty much in-line with what I think what
the SDM is trying to say: it has implicit semi-serialization (next
memory
operation won't proceed until itc.d finishes).


> - It uses some "nta"

Do you have any performance data showing that nta is a win?

- Ken
