From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 20 Nov 2000 15:34:33 +0000
Subject: Re: [Linux-ia64] toolchain status
Message-Id: <marc-linux-ia64-105590678205753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205739@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205739@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 20 Nov 2000, Francis Galiegue wrote:

> On Fri, 17 Nov 2000, H . J . Lu wrote:
> 
> > > 
> > > I'm talking about GNU's stock glibc-2.2.tar.gz here... I didn't know there
> > > were CVS snapshots of it again. Where are they to be found?
> > > 
> > 
> > http://sources.redhat.com/glibc/
> > 
> 
> Hmmm, in snapshots/, the most recent I see is 2.1.3-pre4. This obviously is not
> the good one...

You've missed these bits from the URL above:

    You can access the development source tree a couple of different ways. 

    Anonymous CVS read-only access 

	 cvs -z 9 -d :pserver:anoncvs@anoncvs.cygnus.com:/cvs/glibc login
	 {enter "anoncvs" as the password}
	 cvs -z 9 -d :pserver:anoncvs@anoncvs.cygnus.com:/cvs/glibc co libc
	   

    Read-only web-based CVS access 
	 You can use the cvsweb interface. 

Dan


