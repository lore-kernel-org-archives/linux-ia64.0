From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 19 Sep 2003 17:07:07 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106399128514434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 06:56:21PM +0200, Erich Focht wrote:
> On Thursday 18 September 2003 21:59, Jesse Barnes wrote:
> > ACPI 2.0 SLIT locality table:
> > 010 020 022 042
> > 020 010 042 022
> > 022 042 010 020
> > 042 022 020 010
> 
> That unsymmetric??? Interesting... Of course this saves you the
> headache of explicitely round-robin.

This is just a small system, only 8p, and I was wrong when I said that
we wouldn't have SLIT tables like the one below.  On a larger system
(above 8 nodes) we'll have 4 nodes in each proximity domain, so
round-robin would help us there.  The system above has a topology like
this:

  ------ fast ------
  |    |__v___|    |
  |  3 |      |  2 |
  ------      ------
    | <- slow -> | 
  ------      ------
  |    |______|    |
  |  1 |  ^   |  0 |
  ------ fast ------

Which explains the SLIT.  Of course, on a larger system we'd have the
slow links all connect to a router, which would mean we'd have multiple
nodes in the same domain.

> > Which I think you were worried about?
> 
> I'm still worried about the "normal" kind of machines with more
> symmetric node-distances. TX-7 for example has

Yeah, sorry.  I was smokin' something when I posted that message.  I
really do understand the issue and agree that it's a problem that we
should fix :)

> 10 15 15 15 20 20 20 20
> 15 10 15 15 20 20 20 20
> 15 15 10 15 20 20 20 20
> 15 15 15 10 20 20 20 20
> 20 20 20 20 10 15 15 15
> 20 20 20 20 15 10 15 15
> 20 20 20 20 15 15 10 15
> 20 20 20 20 15 15 15 10

Thanks,
Jesse
