From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Thu, 10 Mar 2005 01:28:00 +0000
Subject: Re: cpu_to_node_map on UP systems
Message-Id: <20050310012800.GB25458@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Luck,

On Wed, 09 Mar 2005, Luck, Tony wrote:

> >On Wednesday, March 9, 2005 11:31 am, Luck, Tony wrote:
> >> Yes, tiger builds ok with SMP=n (if you pull from the
> >> linux-ia64-test-2.6.12 you'll also gets Bjorn's fix to 
> >iosapic so the the
> >> resulting kernel will boot, rather than hang).
> >>
> >> There are still problems with building the generic kernel with SMP=n
> >
> >I thought we had worked all these out awhile ago?  I assume you're merging all 
> >this stuff as fast as you can now that 2.6.12 is open?  Or do 
> >you need me to resend?  If so, let me know when you've got the bulk of your 
> >queue merged and I can fix things up, rediff and resend.
> 
> I'm trying to not go "as fast as I can" this time around ... I'm
> aiming for better review and test of stuff as I put it in (to avoid
> at least some of the messes that I made before).
> 
> At the moment I'm skimming backwards and forwards through the
> backlog picking stuff and loading it into linux-ia64-test-2.6.12
> tree.  I'm going to try to be more systematic about routing
> patches through the test tree before moving them into the release
> tree.
> 
> I have little hope that the SMP=n,GENERIC patches will still apply
> by the time I get back to them ... so a re-diffed fix would be
> appreciated (in a couple of weeks when the backlog has drained).
> 

Let me know when the SMP=n,GENERIC patches have been push into
mainline and I will add a build run for it on the ia64 autobuild:
http://www.gelato.unsw.edu.au/kerncomp/

Darren

> -Tony
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
