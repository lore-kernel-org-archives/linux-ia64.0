From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 08 May 2003 22:17:35 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 8 May 2003 10:07:49 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>If we do have to go the virtual remapping route, my preference would
>be to stick the kernel somewhere in region 5 (0xa..).  Has anyone
>tried that?  It should work fine in principle (modules already live in
>that space).

That loses the alt[id]tlb handling for the kernel code and data.  Is
that going to be a performance problem?


