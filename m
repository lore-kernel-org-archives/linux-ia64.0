From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 30 Mar 2004 15:19:27 +0000
Subject: Re: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <200403300819.27696.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 30 March 2004 12:02 am, Francois Wellenreiter wrote:
> Then I push on the "dump" button that generates an INIT interruption to 
> all the processors. This signal is then caught by PAL, and SAL which 
> calls (with a reason [register GR11] equal to 2) 
> "ia64_monarch_init_handler" on the monarch processor and 
> "ia64_slave_init_handler" on the slave ones (to this point, I hope to be 
> right, isn't it ?).

Yes.  If I understand correctly, you observe that one processor
calls ia64_monarch_init_handler(), and all the others call
ia64_slave_init_handler().  So far, that is correct behavior.

> What I've noticed using traces (and further an ITP tool) is that for 
> each processor the "ia64_monarch_init_handler" is ever called. :-(

Are you saying that more than one processor calls
ia64_monarch_init_handler()?  If so, I think something
is broken.  But I haven't seen that behavior.  Here is
ia64_slave_init_handler():

	GLOBAL_ENTRY(ia64_slave_init_handler)
	1:      br.sptk 1b
	END(ia64_slave_init_handler)

So I'd be surprised to see the slave processors do anything
interesting.

I do know that we are missing some useful behavior in this area --
namely, we don't extract the min-state area for the slave processors,
so we don't get backtraces for the currently-running tasks on them.

Bjorn


