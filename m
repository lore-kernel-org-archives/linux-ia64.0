From: Roland McGrath <roland@redhat.com>
Date: Wed, 29 Aug 2007 07:10:54 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <20070829071054.7526D4D04CC@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The arch_ptrace_stop path there has an issue with SIGKILL races.  But if
the ia64 parts are approved to go in upstream, I can help out with the
generic kernel/signal.c part to make it safe.  Please let me know.


Thanks,
Roland
