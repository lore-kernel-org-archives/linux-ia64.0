From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 07 Aug 2003 02:51:19 +0000
Subject: Re: 2.4 PATCH: gcc 3.3 support
Message-Id: <marc-linux-ia64-106022476310446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106018469231198@msgid-missing>
In-Reply-To: <marc-linux-ia64-106018469231198@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 06, 2003 at 09:59:34AM -0600, Bjorn Helgaas wrote:
> On Wednesday 06 August 2003 9:44 am, H. J. Lu wrote:
> > This is the patch backed ported from 2.6 kernel. However, I got
> > 
> > # modprobe xor
> > raid5: measuring checksumming speed
> >    ia64      :    81.920 MB/sec

This number was under heavy load. I got

Aug  6 09:03:38 gnu-2 kernel: raid5: measuring checksumming speed
Aug  6 09:03:38 gnu-2 kernel:    ia64      :    98.304 MB/sec
Aug  6 09:03:38 gnu-2 kernel: raid5: using function: ia64 (98.304 MB/sec)

with 2.4 kernel when machine was idle.

> > 
> > The old one I got
> > 
> > # modprobe xor
> > raid5: measuring checksumming speed
> >    8regs     :  1769.472 MB/sec
> >    8regs_prefetch:  1753.088 MB/sec
> >    32regs    :  2064.384 MB/sec
> >    32regs_prefetch:  2064.384 MB/sec
> >    ia64      :  2441.216 MB/sec
> > raid5: using function: ia64 (2441.216 MB/sec)
> > 
> > It is very strange.
> 
> That *is* very strange.  I'll wait to apply the patch until we understand
> what's happening.  Have you tried the 2.6 kernel to see what speeds it
> measures?

With 2.6.0-test2, I got

raid5: measuring checksumming speed
   ia64      :    98.304 MB/sec
raid5: using function: ia64 (98.304 MB/sec)

It looks like a separate asm file hurt the number very badly.


H.J.
