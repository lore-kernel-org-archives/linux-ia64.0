From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 07 Aug 2003 17:28:55 +0000
Subject: Re: 2.4 PATCH: gcc 3.3 support
Message-Id: <marc-linux-ia64-106027752029834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106018469231198@msgid-missing>
In-Reply-To: <marc-linux-ia64-106018469231198@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 06, 2003 at 10:57:20PM -0700, H. J. Lu wrote:
> On Wed, Aug 06, 2003 at 09:53:33PM -0700, David Mosberger wrote:
> > >>>>> On Wed, 6 Aug 2003 19:51:19 -0700, "H. J. Lu" <hjl@lucon.org> said:
> > 
> >   H> On Wed, Aug 06, 2003 at 09:59:34AM -0600, Bjorn Helgaas wrote:
> >   >> On Wednesday 06 August 2003 9:44 am, H. J. Lu wrote: > This is
> >   >> the patch backed ported from 2.6 kernel. However, I got
> > 
> >   >> > # modprobe xor > raid5: measuring checksumming speed > ia64 :
> >   >> 81.920 MB/sec
> > 
> >   H> This number was under heavy load. I got
> > 
> >   H> Aug 6 09:03:38 gnu-2 kernel: raid5: measuring checksumming speed
> >   H> Aug 6 09:03:38 gnu-2 kernel: ia64 : 98.304 MB/sec Aug 6 09:03:38
> >   H> gnu-2 kernel: raid5: using function: ia64 (98.304 MB/sec)
> > 
> >   H> with 2.4 kernel when machine was idle.
> > 
> > I can't reproduce this.  With 2.6.0-test2 on a zx6000, I get:
> > 
> > raid5: measuring checksumming speed
> >    ia64      :  2080.768 MB/sec
> > raid5: using function: ia64 (2080.768 MB/sec)
> > 
> 
> Mine is bigsur. I will try old 2.4.2x kernel to see what number I
> will get. It may be just that bigsur has very poor performance on
> xor.
> 

I have verified that removing the separate xor boosts the performance
to

Aug  7 09:39:43 gnu-2 kernel: raid5: measuring checksumming speed
Aug  7 09:39:43 gnu-2 kernel:    8regs     :   753.664 MB/sec
Aug  7 09:39:43 gnu-2 kernel:    8regs_prefetch:   786.432 MB/sec
Aug  7 09:39:43 gnu-2 kernel:    32regs    :  1359.872 MB/sec
Aug  7 09:39:43 gnu-2 kernel:    32regs_prefetch:  1310.720 MB/sec
Aug  7 09:39:43 gnu-2 kernel:    ia64      :  1982.464 MB/sec
Aug  7 09:39:43 gnu-2 kernel: raid5: using function: ia64 (1982.464 MB/sec)

on bigsur.


H.J.
