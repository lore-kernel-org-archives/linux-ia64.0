From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 Nov 2003 23:44:08 +0000
Subject: Re: Fix compiler warning in arch/ia64/kernel/irq_lsapic.c
Message-Id: <marc-linux-ia64-106824936723679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106804372231040@msgid-missing>
In-Reply-To: <marc-linux-ia64-106804372231040@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 5 Nov 2003 20:36:32 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> On Wed, Nov 05, 2003 at 04:14:33PM +0000, Christoph Hellwig wrote:
  >> On Wed, Nov 05, 2003 at 08:44:26AM -0600, Jack Steiner wrote:
  >> > Not sure if you are taking fixes like this right now, but...
  >> > 
  >> > This fixes a compoiler warning that occurs when NR_CPUS is > 64.
  >> 
  >> I think the right fix would be to just not set this value, IIRC
  >> set_affinity is optional.

  Jack> Good point. The field looks like it is optional. Should I update 
  Jack> the patch???

Yes, and please resend it after 2.6.0 is out, as this hardly qualifies
as a critical bug-fix.

	--david
