From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Aug 2004 08:13:32 +0000
Subject: Re: What is MMU_TRACE for?
Message-Id: <16675.4012.367668.929781@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040818042558.GC1170@cse.unsw.EDU.AU>
In-Reply-To: <20040818042558.GC1170@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Aug 2004 14:25:58 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> Hi, The change @ http://tinyurl.com/4g5dz introduced MMU_TRACE,
  Ian> but left the structure to keep the traces in as extern with no
  Ian> corresponding definition.  Is maybe some of the patch missing?
  Ian> What was its original intention?

It's just left-over debugging code.  We should remove it.  What I used
to do is store the traces in kernel-memory and then I'd use Ski to
look at the traces.

  Ian> I actaully wanted to use something like this, so just exported
  Ian> it out to a proc entry (attached just for the archives).

Looks like a fine patch.  Such debug code is normally maintained as
separate patches, though, and not part of the main-line source tree.

	--david
