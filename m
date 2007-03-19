From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Mon, 19 Mar 2007 18:38:45 +0000
Subject: Re: [Fastboot] [PATCH] [REVIEW] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <9a8748490703191138y7ff45fdbl538d2a941414817e@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070319181336.GC12628@strauss.suse.de>
	 <9a8748490703191129h396211e9q59eeea9533d00c38@mail.gmail.com>
	 <20070319183710.GA23499@strauss.suse.de>
In-Reply-To: <20070319183710.GA23499@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jesper.juhl@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org

On 19/03/07, Bernhard Walle <bwalle@suse.de> wrote:
> * Jesper Juhl <jesper.juhl@gmail.com> [2007-03-19 19:29]:
> > >
> > > -void
> > > +int
> > >  register_percpu_irq (ia64_vector vec, struct irqaction *action)
> > >  {
> >
> > Each and every function example in Documentation/CodingStyle has the
> > return type on the same line as the function name, so why not get
> > these in-line while you are modifying them anyway?
>
> Because all other functions in that file are coded this way. I think
> it looks better if you don't change the style in a particular file.
> Am I wrong?
>
Consistency within the file certainly makes sense.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
