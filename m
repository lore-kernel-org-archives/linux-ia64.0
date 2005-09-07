From: david mosberger <dmosberger@gmail.com>
Date: Wed, 07 Sep 2005 17:59:45 +0000
Subject: Re: [patch] delete sync.i in ia64_switch_to()
Message-Id: <ed5aea4305090710595313fd96@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070723.j877N9g25144@unix-os.sc.intel.com>
In-Reply-To: <200509070723.j877N9g25144@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/7/05, Jim Hull <jim.hull@hp.com> wrote:
> That sync.i is not old code - it is required.

Yes, the sync.i was added by Asit at some point precisely for the
reasons you explained.  I believe we concluded at the time that the
"mf" wasn't needed since we'd be guaranteed to have a fence in the
execution-path anyhow (IIRC, it was due to locks being
acquired/released on the paths in question).  I'm not sure, however,
whether this point has been considered when kernel-preemption support
was added.  The folks caring about CONFIG_PREEMPT may want to
reconsider that issue if not.

  --david
