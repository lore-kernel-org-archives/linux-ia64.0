From: david mosberger <dmosberger@gmail.com>
Date: Fri, 22 Jul 2005 06:00:56 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <ed5aea4305072123004eb9be4d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/21/05, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> On Wed, Jul 20, 2005 at 03:31:39PM +1000, Ian Wienand wrote:
> > After some investigation I believe this is do with differences between
> > the alignment of variables on the stack between gcc 3 and 4 and the
> > ski simulator.
> 
> For tracking purposes I've put this in the gcc bugzilla
> 
> http://gcc.gnu.org/bugzilla/show_bug.cgi?id"605

Regardless of what GCC is doing, this seems to be a ski bug.  I no
longer have access to the Ski sources, so there is nothing I can do. 
Dan, do you want to take a quick look to see if anything obvious is
wrong in that area?

  --david
-- 
Mosberger Consulting, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane                                                    
        Fremont, CA 94536
