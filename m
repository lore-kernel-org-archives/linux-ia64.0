From: Bjorn Helgaas <bjorn_helgaas@hp.com>(by way of Bjorn Helgaas <bjorn_helgaas@hp.c
Date: Tue, 11 Mar 2003 16:23:13 +0000
Subject: Re: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709806023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805882@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805882@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Sorry if this is a duplicate; I sent it yesterday, but it bounced due
to an HP mail problem.]

On Monday 03 March 2003 4:52 pm, Keith Owens wrote:
> On Mon, 3 Mar 2003 09:47:49 -0700, 
> Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:
> >Wow, somebody is actually looking at the BK tree :-)
> 
> I do not use BK.  Because I work on PRCS I am not comfortable with
> using BK, there is a possible conflict with the BK 'no competitor'
> clause.  I was looking at Marcelo's 2.4.21-pre5 patch.

Yeah, that makes sense.  BK is extremely convenient for me, because
it makes it so easy to track what Marcelo and David are doing, but
I certainly don't want to force that on anybody else.

It feels like the "right thing" to make plain old patches available
whenever I publish changes via BK, and I'm willing to do that if
there's any interest in it.

Bjorn




