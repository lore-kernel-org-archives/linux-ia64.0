From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Mar 2003 23:35:58 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709806007@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 10 February 2003 8:06 pm, David Mosberger wrote:
> >>>>> On Sun, 9 Feb 2003 16:19:20 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:
> 
>   Matt> I'm having some difficulty "demand paging" register backing
>   Matt> store from userspace (i.e. using SIGSEGV to map pages in on
>   Matt> demand).
> 
> OK, I looked into this.  The patch below should fix the problem.
> Bjorn, you might want to consider applying the same patch for 2.4.xx
> (with some extra testing).

I applied this patch to 2.4.

Bjorn


